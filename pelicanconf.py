#!/usr/bin/env python
# -*- coding: utf-8 -*- #

AUTHOR = u'Dávid'
SITENAME = u'thewagner.net'
SITEURL = 'http://thewagner.net'

TIMEZONE = 'Europe/Paris'

DEFAULT_LANG = u'en'
DEFAULT_CATEGORY = 'blog'

# Blogroll
LINKS =  (('Pelican', 'http://docs.notmyidea.org/alexis/pelican/'),
          ('Python.org', 'http://python.org'),
          ('Jinja2', 'http://jinja.pocoo.org'),
          ('You can modify those links in your config file', '#'),)
LINKS = ()

MENUITEMS = [('archives', '/archives.html')]

# Social widget
SOCIAL = (('Facebook', 'https://www.facebook.com/wagdav'),
          ('G+', 'https://plus.google.com/101685366407007540559/posts'),
          ('Linkedin',
           'http://ch.linkedin.com/pub/d%C3%A1vid-w%C3%A1gner/6b/556/a84'))

DEFAULT_PAGINATION = 10

#FEED_DOMAIN = 'http://thewagner.net'

ARTICLE_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/'
ARTICLE_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'
ARTICLE_LANG_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}-{lang}/'
ARTICLE_LANG_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}-{lang}/index.html'

FILES_TO_COPY = (('extra/CNAME', 'CNAME'),
                 ('extra/README', 'README'))


DELETE_OUTPUT_DIRECTORY = True
