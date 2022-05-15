class ProfileDecorator < ApplicationDecorator
  # Return a Hash of the profile fields that should be rendered for a given
  # display area, e.g. :left_sidebar
  def ui_attributes_for(area:, raw: false)
    plucked = raw ? %i[attribute_name attribute_name] : %i[label attribute_name]
    fields = ProfileField.public_send(area).pluck(*plucked).to_h
    fields.transform_values { |attribute_name| data[attribute_name] }.compact_blank
  end
end
