# -*- coding: utf-8 -*-
"""
Blogger->Settings->Other->export blog
"""
from subprocess import Popen, PIPE
import datetime
import os
import string
import unicodedata
import xml.etree.ElementTree as ET


# These tags identify the ATOM elements in the downloaded XML.
atom = {}
w3org = '{http://www.w3.org/2005/Atom}'
for k in ['content', 'author', 'title', 'entry', 'category', 'published']:
    atom[k] = w3org + k


def ispost(entry):
    category = entry.find(atom['category'])
    return category.attrib['term'].endswith('post')


def iscomment(entry):
    category = entry.find(atom['category'])
    return category.attrib['term'].endswith('comment')


def get_date(published):
    d, t = published.split('T')
    return datetime.datetime.strptime(d, '%Y-%m-%d')


def strip_accents(s):
    return ''.join((c for c in unicodedata.normalize('NFD', s) if
                    unicodedata.category(c) != 'Mn'))


def valid_filename(s):
    """
    Convert a string to a valid filename.
    """
    valid_chars = "-_.() %s%s" % (string.ascii_letters, string.digits)
    return ''.join(c for c in s if c in valid_chars)


def sanitize_string(s):
    s = strip_accents(s)
    s = valid_filename(s)
    s = s.replace(' ', '-')
    return s


def entry_to_post(entry):
    d = {}

    title = entry.find(atom['title'])
    content = entry.find(atom['content'])
    published = entry.find(atom['published'])
    tags = [c.attrib['term'] for c in entry.findall(atom['category'])
                             if not c.attrib['term'].endswith('post')]

    d['title'] = unicode(title.text)
    d['content'] = unicode(content.text)
    d['published'] = get_date(published.text)
    d['tags'] = tags

    return d


def post_filename(post, extension='html'):
    """
    Generate a sane filename for the post.
    """
    return (post['published'].strftime('%Y-%m-%d') + '-' +
            sanitize_string(post['title']) + '.' + extension)


def blogger2html(xml):
    """
    Convert the XML file saved from Blogger to a set of html posts.
    """
    return process_posts(xml, html)


def process_posts(xml, converter, **args):
    posts = [elem for elem in xml.iter(atom['entry']) if ispost(elem)]
    #comments = [elem for elem in xml.iter(atom['entry']) if iscomment(elem)]
    return [converter(entry_to_post(entry), **args) for entry in posts]


def write_content(route_content, directory='.'):
    for route, content in route_content:
        fname = os.path.join(directory, route)
        if not os.path.isdir(os.path.dirname(fname)):
            os.makedirs(os.path.dirname(fname))
        with open(fname, 'w') as f:
            f.write(content.encode('utf-8'))


def pandoc(s, read='html', write='rst'):
    """
    Call pandoc to convert between markups.
    """
    p = Popen(['pandoc', '-r', read, '-w', write], stdin=PIPE, stdout=PIPE)
    return p.communicate(input=s.encode('utf-8'))[0].decode('utf-8')


def markdown(post):
    body = pandoc(post['content'], read='html', write='markdown')

    header = ''
    header += '---\n'
    header += 'title: %s\n' % post['title']
    header += u'author: Dávid\n'
    header += 'date: %s\n' % post['published'].strftime('%Y-%m-%d')
    header += 'tags: hu\n'
    header += '---\n'
    header += '\n'

    content = header + body
    return post_filename(post, 'md'), content


def html(post):
    return post_filename(post), post['content']


def rst(post, split_by_date=False):
    filename = post_filename(post, 'rst')

    if split_by_date:
        date, filename = filename[:10], filename[11:]
        year, month, day = date.split('-')
        filename = os.path.join(year, month, day, filename)

    body = pandoc(post['content'], read='html', write='rst')

    header = ''
    header += '%s\n' % post['title']
    header += len(post['title']) * '=' + '\n\n'
    header += ':tags: %s\n' % (', '.join(post['tags']),)
    header += '\n'
    content = header + body

    print filename

    return filename, content


if __name__ == '__main__':
    xml = ET.parse('blog-12-22-2012.xml')
    content = process_posts(xml, rst, split_by_date=False)
    write_content(content, './content/aventures')
