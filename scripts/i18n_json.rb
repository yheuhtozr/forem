# rubocop:disable Style/StringLiterals, Style/TopLevelMethodDefinition, Lint/MissingCopEnableDirective
require 'yaml'
require 'oj'
require 'deepsort'
require 'active_support'
require 'active_support/core_ext'

yamls = Dir.new "#{__dir__}/../app/i18n"
js1 = Dir.new "#{__dir__}/../app/javascript/i18n"
js2 = Dir.new "#{__dir__}/../public/javascripts/i18n"

MAP = {
  __orphan: [%w[common crayons errors feed flagUser gitHub main markdownLint modActions notifications onboarding org profile readingList templates], %w[archivedPosts csrf loginModal unitAgo userAlertModal]],
  actions: {
    copy: {
      __scope: ['clipboard'],
      text: ['message'],
    },
  },
  articles: {
    __orphan: [%w[duration pinned timeAgo]],
    conduct: {
      __scope: ['articles'],
      report: [true],
    },
    for_org: [true, true],
    _for_org: { html: %w[start end org], html_trans: [%w[start end], %w[org]] },
    reading_time: [true, true],
    save: {
      __orphan: [%w[unsave], %w[remove]],
      initial: ['save', true],
      success: ['saved', true],
    },
  },
  campaign: {
    __orphan: [nil, %w[close]],
  },
  clipboard: {
    __orphan: [%w[alt_text copied copy copy_markdown]],
  },
  comments: {
    __orphan: [%w[all blocked delete hide number subscription], %w[invalid read replies sent uploaded uploading]],
    footer: {
      __scope: [nil, 'comments.form'],
      heart: {
        __scope: [nil, 'comments'],
        count: [nil, 'num_likes'],
        _count: { html: %w[num likes] },
      },
      reply: {
        aria_label: [nil, true],
        placeholder: [nil, true],
        text: [nil, true],
      },
      thread: {
        __scope: [nil, 'comments'],
        text: [nil, 'thread'],
      },
    },
    menu: {
      __orphan: [nil, %w[delete edit]],
      aria_label: [nil, true],
      copy: {
        aria_label: [nil, true],
        text: [nil, true],
      },
      report: {
        __orphan: [nil, %w[text]],
        aria_label: [nil, true],
      },
      settings: {
        __orphan: [nil, %w[text]],
        aria_label: [nil, true],
      },
    },
    messages: {
      create: {
        __scope: ['comments.messages'],
        failure: [true],
        success: [true],
      },
    },
    plucked: {
      __scope: ['comments', 'comments.summary'],
      empty: [true, true],
    },
    write: {
      __scope: [nil, 'comments.form'],
      field: {
        __scope: [nil, 'comments.form'],
        guide: {
          __scope: [nil, 'comments.form'],
          title: [nil, 'guide'],
        },
        submit: [nil, 'submit_upload'],
        templates: [nil, true],
        upload: [nil, true],
        use: [nil, true],
      },
      cancel: [nil, true],
      preview: [nil, true],
      submit: [nil, true],
      template: {
        create: {
          __scope: [nil, 'comments.form.template'],
          desc: [nil, true],
          subtitle: [nil, 'create'],
        },
        moderator: [nil, true],
        personal: [nil, true],
      },
    },
  },
  dashboard: {
    __orphan: [nil, %w[comments]],
    article: {
      __orphan: [nil, %w[admin translate]],
      edit: {
        __scope: [nil, 'dashboard.article'],
        text: [nil, 'edit'],
      },
      manage: {
        __scope: [nil, 'dashboard.article'],
        text: [nil, 'manage'],
      },
      stats: [nil, true],
    },
    following_tags: {
      __scope: [nil, 'tags.following'],
      anti: {
        title: [nil, true],
        text: [nil, true],
      },
      number: {
        __scope: [nil, 'tags.following.weight'],
        aria_label: [nil, true],
      },
    },
    posts: {
      __scope: ['editor'],
      personal: [true],
    }
  },
  editor: {
    __orphan: [%w[a11y aria_label aria_new content help image leave publish publishConfirm publishing revert revert_button save save_draft saving saving_draft toolbar], %w[continue]],
    close: {
      __scope: ['editor'],
      title: ['close']
    },
    cover: {
      __orphan: [%w[aria_label number uploading]],
      add: [true],
      change: [true],
    },
    create: [true],
    edit: ['editor.tabs.edit'],
    modes: ['editor.tabs.aria_label'],
    new_title: [true],
    options: {
      __orphan: [%w[done heading series title unpublish url]],
      lang: {
        __orphan: [%w[desc existing label]],
      },
    },
    preview: ['editor.tabs.preview', true],
    translate: [true],
  },
  feedback: {
    __orphan: [%w[block blocked desc heading message report_message submitted why]],
    form: {
      __scope: ['feedback'],
      rude_or_vulgar: [true],
      harassment: [true],
      spam: [true],
      listings: [true],
    },
  },
  followButts: {
    __orphan: [%w[aria_followback edit follow_small followback following following_small]],
  },
  listings: {
    __orphan: [%w[actions all available bumped buy category create created credits expired expires filter made modal more options personal]],
    form: {
      body_markdown: {
        desc: [true],
      },
      category: {
        label: [true],
        summary: [true],
      },
      expiry: {
        desc: [true],
      },
      organization: {
        __scope: ['listings.org'],
        desc: [true],
      },
      title: {
        placeholder: [true],
      }
    },
    heading: [true],
  },
  podcasts: {
    __orphan: [%w[today], %w[rate]],
    tag: [true],
    time: [nil, true],
  },
  reactions: {
    __orphan: [%w[number]]
  },
  search: {
    __orphan: [%w[aria_label empty]],
    placeholder: [true],
  },
  stats: {
    __orphan: [%w[charts comments external followers new_followers reactions readers reads this_month this_week]],
  },
  sticky: {
    __scope: ['users.card'],
    created_at: [true],
    email: [true],
    location: [true],
  },
  tags: {
    __orphan: [%w[aria_label hide placeholder rules view]],
  },
  users: {
    custom: {
      langs: {
        __scope: ['editor.options.lang'],
        aria_label: [true],
        cla: [true],
        others: [true],
        select: [true],
        site: [true],
        special: [true],
      },
    },
    details: [true, true],
    follow: [true],
    profile_fields: {
      __scope: ['users.card'],
      education: [true],
      work: [true],
    }
  },

  helpers: {
    application_helper: {
      follow: {
        aria_label: {
          __scope: ['followButts.aria_follow'],
          Organization: [true],
          Tag: [true],
          User: [true],
          default: [true],
        },
        text: {
          __scope: ['followButts.follow'],
          Organization: [true],
          Tag: [true],
          User: [true],
          default: [true],
        },
      },
    },
    comments_helper: {
      __scope: [nil, 'comments'],
      like: [nil, true],
      nbsp_likes: [nil, 'likes'],
      _nbsp_likes: { html: [] },
    },
    label: {
      listing: {
        body_markdown: ['listings.form.body_markdown.label'],
        expires_at: ['listings.form.expiry.label'],
        organization_id: ['listings.org.label'],
        tag_list: ['tags.label'],
        title: ['listings.form.title.label'],
      },
    },
  },
}.freeze

# https://github.com/dam13n/ruby-bury/blob/140c8cf1ad95d9e3c5148db3b331fe92061de86f/hash.rb
class Hash
  def bury(*args)
    if args.count < 2 # rubocop:disable Style/GuardClause
      raise ArgumentError, "2 or more arguments required"
    elsif args.count == 2
      self[args[0]] = args[1]
    else
      arg = args.shift
      self[arg] = {} unless self[arg]
      self[arg].bury(*args) unless args.empty?
    end

    self
  end
end

class HTMLTag < String
  def init_with(coder)
    initialize coder.scalar
  end
end

class PlTag < Hash
  def init_with(coder)
    initialize coder.map
  end
end

YAML.add_tag '!html', HTMLTag
YAML.add_tag '!pl', PlTag

PLURALS = {
  en: { 1 => 'one', 'n' => 'other' },
  ja: { 'n' => 'other' },
}.freeze

def lang_pl(code)
  code.split('-')[0].intern
end

def insert_string(tree, path, text, **options)
  case text
  when HTMLTag
    subbed = text.dup
    options[:html]&.each { |name| subbed.gsub! "%{#{name}}", "%{- #{name}}" }
    options[:html_trans]&.each&.with_index { |pair, i|
      if pair[1]
        subbed.gsub!("%{#{pair[0]}}", "<#{i}>")
        subbed.gsub!("%{#{pair[1]}}", "</#{i}>")
      elsif pair.present?
        subbed.gsub!("%{#{pair[0]}}", "<#{i}>%{#{pair[0]}}</#{i}>")
      end
    }
    tree.bury(*path, subbed)
  when String
    tree.bury(*path, text)
  end
end

def insert(entry, lang, tree, path, **options)
  options.delete(options[:static] ? :html_trans : :html)
  case entry
  when PlTag
    pl = PLURALS[lang_pl(lang)]
    hash = entry[0] # ?????
    pl.each do |k, v|
      t = hash[k] ? k : 'n'
      case hash[t]
      when String, HTMLTag
        hash[t].gsub! '%1', '%{count}' # rubocop:disable Style/FormatStringToken
        insert_string tree, v ? path[0..-2] + ["#{path[-1]}_#{v}"] : path, hash[t], **options
      else
        raise "Unsupported text value! #{lang}:#{path.join '.'}(#{t}) = (#{hash[t].class}) #{hash[t].inspect}"
      end
    end
  when String, HTMLTag
    insert_string tree, path, entry, **options
  else
    raise "Unsupported YAML value! #{lang}:#{path.join '.'} = (#{entry.class}) #{entry.inspect}"
  end
end

def convert(doc, lang, node, tree, which, scope = [], path = [], **options) # rubocop:disable Metrics/CyclomaticComplexity
  entry = scope.empty? ? doc : doc.dig(*scope)
  my_scope = path
  case node
  when Hash
    if (sc = node[:__scope]&.[](which))
      my_scope = sc.split '.'
      options[:scoped] = true
    end
    node.reject { |k, _| k.start_with? '_' }.each { |k, v| convert doc, lang, v, tree, which, scope + [k.to_s], my_scope + [k.to_s], **options }
  when Array
    if (key = scope.last)
      options.merge! MAP.dig(*scope[0..-2].map(&:intern), "_#{key}".intern) || {}
    end
    options[:static] = which.positive?
    case node[which]
    when TrueClass
      insert entry, lang, tree, my_scope, **options
    when String
      written_path = node[which].split('.')
      my_path = options[:scoped] || written_path.size < 2 ? my_scope[0..-2] + written_path : written_path
      insert entry, lang, tree, my_path, **options
    when NilClass
      # do nothing
    else
      raise "Unsupported content type! #{my_scope.join '.'}[#{which}] = #{node[which].inspect}"
    end
  else
    raise "Unsupported object! #{scope.join '.'} = #{node.inspect}"
  end
end

def orphan(lang, map, tree, existing, which, path = [])
  node = path.empty? ? map : map.dig(*path.map(&:intern))
  if (orphans = node[:__orphan]&.[](which))
    orphans.each do |op|
      raise "Already Exists! #{path.join '.'}.#{op}[#{which}] = #{tree.dig(*path, op).inspect}" if tree.dig(*path, op)

      tree.bury(*path, op, existing.dig(*path, op)) if existing.dig(*path, op)
      PLURALS[lang_pl(lang)].each do |_, suffix|
        suffixed = "#{op}_#{suffix}"
        if (pl = existing.dig(*path, suffixed))
          tree.bury(*path, suffixed, pl)
        end
      end
    end
  end
  node.select { |k, v| v.instance_of?(Hash) && !k.start_with?('_') }.each do |sub, _|
    orphan lang, map, tree, existing, which, (path + [sub.to_s])
  end
end

def parse(doc, lang, existing, which)
  tree = {}
  convert doc, lang, MAP, tree, which
  orphan lang, MAP, tree, existing, which

  tree.deep_sort
end

Dir.glob("**/*.yml", base: yamls).uniq.compact.map { |name| File.basename name, '.*' }.each do |base|
  doc = {}
  Dir.glob("**/#{base}.yml", base: yamls) { |f| doc.deep_merge! YAML.load_file("#{yamls.path}/#{f}") }
  doc.merge! doc.delete('v')
  [js1, js2].each.with_index do |dir, which|
    json = "#{dir.path}/#{base}.json"
    old = JSON.parse File.read(json, encoding: 'utf-8:utf-8')
    new = parse doc, base, old, which
    File.open(json, 'w:utf-8') { |out| out.puts JSON.pretty_generate(new).gsub(/[\p{WSpace}&&\S]/) { '\u%04X' % $&.ord } }
  end
end
