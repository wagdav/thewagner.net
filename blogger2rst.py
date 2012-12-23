"""
Blogger->Settings->Other->export blog
"""
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


def post_filename(post, extension='html'):
    return (post['published'].strftime('%Y-%m-%d') + '-' +
            sanitize_string(post['title']) + '.' + extension)


def post_filecontent(post):
    return post['content']


def entry_to_post(entry):
    d = {}

    title = entry.find(atom['title'])
    content = entry.find(atom['content'])
    published = entry.find(atom['published'])

    d['title'] = unicode(title.text)
    d['content'] = unicode(content.text)
    d['published'] = get_date(published.text)

    return d


def blogger2html(xml, directory):
    """
    Convert the XML file saved from Blogger to a set of html posts.
    """
    posts = [elem for elem in xml.iter(atom['entry']) if ispost(elem)]
    #comments = [elem for elem in xml.iter(atom['entry']) if iscomment(elem)]

    if not os.path.isdir('blog'):
        os.mkdir('blog')

    for entry in posts:
        post = entry_to_post(entry)

        fname = os.path.join('blog', post_filename(post))
        with open(fname, 'w') as f:
            f.write(post_filecontent(post).encode('utf-8'))


if __name__ == '__main__':
    xml = ET.parse('blog-12-22-2012.xml')
    blogger2html(xml, './blog')
