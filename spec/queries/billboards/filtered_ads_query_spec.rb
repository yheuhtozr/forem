require "rails_helper"

RSpec.describe Billboards::FilteredAdsQuery, type: :query do
  let(:placement_area) { "post_sidebar" }

  def create_display_ad(**options)
    defaults = {
      approved: true,
      published: true,
      placement_area: placement_area,
      display_to: :all
    }
    create(:display_ad, **options.reverse_merge(defaults))
  end

  def filter_ads(**options)
    defaults = {
      billboards: DisplayAd, area: placement_area, user_signed_in: false
    }
    described_class.call(**options.reverse_merge(defaults))
  end

  context "when ads are not approved or published" do
    let!(:unapproved) { create_display_ad approved: false }
    let!(:unpublished) { create_display_ad published: false }
    let!(:display_ad) { create_display_ad }

    it "does not display unapproved or unpublished ads" do
      filtered = filter_ads
      expect(filtered).not_to include(unapproved)
      expect(filtered).not_to include(unpublished)
      expect(filtered).to include(display_ad)
    end
  end

  context "when considering article_tags" do
    let!(:no_tags) { create_display_ad cached_tag_list: "" }
    let!(:mismatched) { create_display_ad cached_tag_list: "career" }

    it "will show no-tag display ads if the article tags do not contain matching tags" do
      filtered = filter_ads(article_id: 11, article_tags: %w[javascript])
      expect(filtered).not_to include(mismatched)
      expect(filtered).to include(no_tags)
    end

    it "will show display ads with no tags set if there are no article tags" do
      filtered = filter_ads(article_id: 11, article_tags: [])
      expect(filtered).not_to include(mismatched)
      expect(filtered).to include(no_tags)
    end

    context "when available ads have matching tags" do
      let!(:matching) { create_display_ad cached_tag_list: "linux, git, go" }

      it "will show the display ads that contain tags that match any of the article tags" do
        filtered = filter_ads article_id: 11, article_tags: %w[linux productivity]
        expect(filtered).not_to include(mismatched)
        expect(filtered).to include(matching)
        expect(filtered).to include(no_tags)
      end
    end
  end

  context "when considering user_tags" do
    let!(:no_tags) { create_display_ad placement_area: "feed_first", cached_tag_list: "" }
    let!(:mismatched) { create_display_ad placement_area: "feed_first", cached_tag_list: "career" }

    it "will show no-tag display ads if the user tags do not contain matching tags" do
      filtered = filter_ads(area: "feed_first", user_tags: %w[javascript])
      expect(filtered).not_to include(mismatched)
      expect(filtered).to include(no_tags)
    end

    it "will show display ads with no tags set if there are no user tags" do
      filtered = filter_ads(area: "feed_first", user_tags: [])
      expect(filtered).not_to include(mismatched)
      expect(filtered).to include(no_tags)
    end

    context "when available ads have matching tags" do
      let!(:matching) { create_display_ad placement_area: "feed_first", cached_tag_list: "linux, git, go" }

      it "will show the display ads that contain tags that match any of the user tags" do
        filtered = filter_ads area: "feed_first", user_tags: %w[linux productivity]
        expect(filtered).not_to include(mismatched)
        expect(filtered).to include(matching)
        expect(filtered).to include(no_tags)
      end
    end
  end

  context "when considering users_signed_in" do
    let!(:for_logged_in) { create_display_ad display_to: :logged_in }
    let!(:for_logged_out) { create_display_ad display_to: :logged_out }
    let!(:for_all_users) { create_display_ad display_to: :all }

    it "always shows :all, only shows -in/-out appropriately" do
      filtered = filter_ads user_signed_in: true
      expect(filtered).to contain_exactly(for_logged_in, for_all_users)

      filtered = filter_ads user_signed_in: false
      expect(filtered).to contain_exactly(for_logged_out, for_all_users)
    end
  end

  context "when considering article_exclude_ids" do
    let!(:ex_article1) { create_display_ad exclude_article_ids: "11,12" }
    let!(:another_ex_article2) { create_display_ad exclude_article_ids: "12,13" }
    let!(:no_excludes) { create_display_ad }

    it "will show display ads that exclude articles appropriately" do
      filtered = filter_ads article_id: 11
      expect(filtered).to contain_exactly(another_ex_article2, no_excludes)

      filtered = filter_ads article_id: 12
      expect(filtered).to contain_exactly(no_excludes)

      filtered = filter_ads article_id: 13
      expect(filtered).to contain_exactly(ex_article1, no_excludes)

      filtered = filter_ads article_id: 14
      expect(filtered).to contain_exactly(ex_article1, another_ex_article2, no_excludes)
    end
  end

  context "when considering audience segmentation" do
    let!(:in_segment) { create(:user) }
    let!(:audience_segment) { create(:audience_segment, type_of: :no_posts_yet) }
    let!(:targets_segment) { create_display_ad audience_segment: audience_segment }
    let!(:no_targets) { create_display_ad display_to: :all }
    let!(:not_in_segment) { create(:user) } # won't be in any segment

    before do
      _targets_other = create_display_ad audience_segment: create(:audience_segment)
    end

    it "targets users in/out of segment appropriately" do
      filtered = filter_ads user_signed_in: true, user_id: in_segment
      expect(filtered).to contain_exactly(targets_segment, no_targets)

      filtered = filter_ads user_signed_in: true, user_id: not_in_segment
      expect(filtered).to contain_exactly(no_targets)

      filtered = filter_ads user_signed_in: false
      expect(filtered).to contain_exactly(no_targets)
    end
  end

  context "when considering ads with organization_id" do
    let!(:in_house_ad) { create_display_ad type_of: :in_house }

    let(:organization) { create(:organization) }
    let(:other_org) { create(:organization) }
    let(:no_ads_org) { create(:organization) }
    let!(:community_ad) { create_display_ad organization_id: organization.id, type_of: :community }
    let!(:other_community) { create_display_ad organization_id: other_org.id, type_of: :community }

    let!(:external_ad) { create_display_ad organization_id: organization.id, type_of: :external }
    let!(:other_external) { create_display_ad organization_id: other_org.id, type_of: :external }

    it "always shows :community ad if matching, otherwise shows in_house/external", :aggregate_failure do
      filtered = filter_ads organization_id: organization.id
      expect(filtered).to contain_exactly(community_ad)
      expect(filtered).not_to include(other_community)

      filtered = filter_ads organization_id: no_ads_org.id
      expect(filtered).to contain_exactly(in_house_ad)
      expect(filtered).not_to include(other_community)

      filtered = filter_ads organization_id: nil
      expect(filtered).to contain_exactly(in_house_ad, external_ad, other_external)
      expect(filtered).not_to include(community_ad, other_community)
    end

    it "suppresses external ads when permit_adjacent_sponsors is false" do
      filtered = filter_ads organization_id: organization.id, permit_adjacent_sponsors: false
      expect(filtered).to contain_exactly(community_ad)
      expect(filtered).not_to include(other_community)

      filtered = filter_ads organization_id: nil, permit_adjacent_sponsors: false
      expect(filtered).to contain_exactly(in_house_ad)
      expect(filtered).not_to include(other_community)
    end
  end

  context "when considering home hero ads" do
    let!(:in_house_ad) { create_display_ad placement_area: "home_hero", type_of: :in_house }

    let(:organization) { create(:organization) }
    let(:other_org) { create(:organization) }
    let!(:community_ad) { create_display_ad organization_id: organization.id, type_of: :community }
    let!(:other_community) { create_display_ad organization_id: other_org.id, type_of: :community }

    it "always shows home hero ads only" do
      filtered = filter_ads(area: "home_hero")
      expect(filtered).to contain_exactly(in_house_ad)
      expect(filtered).not_to include(other_community)
      expect(filtered).not_to include(community_ad)
    end
  end

  context "with target geolocations" do
    let!(:no_targets) { create_display_ad }
    let!(:targets_canada) { create_display_ad(target_geolocations: "CA") }
    let!(:targets_new_york_and_canada) { create_display_ad(target_geolocations: "US-NY, CA") }
    let!(:targets_california_and_texas) { create_display_ad(target_geolocations: "US-CA, US-TX") }
    let!(:targets_quebec_and_newfoundland) { create_display_ad(target_geolocations: "CA-QC, CA-NL") }
    let!(:targets_maine_alberta_and_ontario) { create_display_ad(target_geolocations: "US-ME, CA-AB, CA-ON") }

    context "when location targeting feature is not enabled" do
      before do
        allow(FeatureFlag).to receive(:enabled?).with(:billboard_location_targeting).and_return(false)
      end

      it "ignores the target geolocations" do
        filtered = filter_ads(location: "CA-NL") # User is in Newfoundland, Canada

        expect(filtered).to include(
          no_targets,
          targets_canada,
          targets_new_york_and_canada,
          targets_california_and_texas,
          targets_quebec_and_newfoundland,
          targets_maine_alberta_and_ontario,
        )
      end
    end

    context "when location targeting feature is enabled" do
      before do
        allow(FeatureFlag).to receive(:enabled?).with(:billboard_location_targeting).and_return(true)
      end

      it "shows only billboards with no targeting if no location is provided" do
        filtered = filter_ads
        expect(filtered).to include(no_targets)
        expect(filtered).not_to include(
          targets_canada,
          targets_new_york_and_canada,
          targets_california_and_texas,
          targets_quebec_and_newfoundland,
          targets_maine_alberta_and_ontario,
        )
      end

      it "shows only billboards whose target location includes the specified location" do
        filtered = filter_ads(location: "CA-NL") # User is in Newfoundland, Canada

        expect(filtered).to include(
          no_targets,
          targets_canada,
          targets_new_york_and_canada,
          targets_quebec_and_newfoundland,
        )
        expect(filtered).not_to include(
          targets_california_and_texas,
          targets_maine_alberta_and_ontario,
        )

        filtered = filter_ads(location: "US-CA") # User is in California, USA
        expect(filtered).to include(
          no_targets,
          targets_california_and_texas,
        )
        expect(filtered).not_to include(
          targets_canada,
          targets_new_york_and_canada,
          targets_quebec_and_newfoundland,
          targets_maine_alberta_and_ontario,
        )
      end

      it "shows only billboards targeting the country specifically if no region is provided" do
        filtered = filter_ads(location: "CA") # User is in "Canada"

        expect(filtered).to include(
          no_targets,
          targets_canada,
          targets_new_york_and_canada,
        )
        expect(filtered).not_to include(
          targets_california_and_texas,
          targets_quebec_and_newfoundland,
          targets_maine_alberta_and_ontario,
        )
      end
    end
  end
end
