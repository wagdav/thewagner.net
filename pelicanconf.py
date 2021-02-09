AUTHOR = 'David Wagner'
SITENAME = 'The Wagner'

PATH = 'content'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = 'en'

ARTICLE_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/'
ARTICLE_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'
ARTICLE_LANG_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}-{lang}/'
ARTICLE_LANG_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}-{lang}/index.html'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Social widget
SOCIAL = ()

DEFAULT_PAGINATION = False
DISPLAY_CATEGORIES_ON_MENU = False

STATIC_PATHS = [
    "CNAME",
    "downloads",
    "images",
    "README",
]

THEME = "theme"

PLUGIN_PATHS = ["./plugins/render-math/pelican/plugins"]
PLUGINS = ["render_math"]
