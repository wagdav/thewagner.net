#!/usr/bin/env python3
""" Create a new blog post """

import datetime
import argparse
import os.path


def valid_date(date_string):
    """ Return True if the provided date string is a valid date """

    try:
        return datetime.datetime.strptime(date_string, "%Y-%m-%d")
    except ValueError:
        msg = "Not a valid date: '{0}'.".format(date_string)
        raise argparse.ArgumentTypeError(msg)


def format_date(date=None):
    """ Return the specified date in the desired format.  If None is given the
    current time is used
    """

    if not date:
        date = datetime.datetime.now()

    return date.strftime('%Y-%m-%d')


def make_post_filepath(date, slug):
    """ Return the desired filename of the post """

    name = '{}-{}.rst'.format(format_date(date), slug)
    return os.path.join('content', name)


def create_empty_post(date, slug):
    """ Create an empty blog post """

    filepath = make_post_filepath(date, slug)

    open(filepath, 'a').close()


def main():
    """ The main function """
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument('slug')
    parser.add_argument(
        '--date',
        help='The date of the post (format YYYY-MM-DD)',
        type=valid_date,
        default=format_date())

    args = parser.parse_args()

    create_empty_post(args.date, args.slug)


if __name__ == '__main__':
    main()
