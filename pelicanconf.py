#!/usr/bin/env python
# -*- coding: utf-8 -*- #

AUTHOR = u'David Wagner'
SITENAME = u'The Wagner'
SITEURL = 'https://thewagner.net'
RELATIVE_URLS = True

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = u'en'
DEFAULT_CATEGORY = 'blog'

LINKS = ()

MENUITEMS = [('archives', '/archives.html')]

# Social widget
SOCIAL = (('GitHub', 'https://github.com/wagdav'),
          ('Linkedin',
           'http://ch.linkedin.com/pub/d%C3%A1vid-w%C3%A1gner/6b/556/a84'),
          ('Facebook', 'https://www.facebook.com/wagdav'),
          ('G+', 'https://plus.google.com/101685366407007540559/posts'))

DEFAULT_PAGINATION = 10

ARTICLE_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/'
ARTICLE_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'
ARTICLE_LANG_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}-{lang}/'
ARTICLE_LANG_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}-{lang}/index.html'

DELETE_OUTPUT_DIRECTORY = True

THEME = 'themes/aboutwilson'

STATIC_PATHS = ['images', 'downloads']

PLUGIN_PATHS = ['./plugins']
PLUGINS = [
    'liquid_tags.pygalcharts',
    'render_math',
]
