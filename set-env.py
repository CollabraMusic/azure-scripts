#!/usr/bin/python

import sys, argparse, json

def main(argv):
    parser = argparse.ArgumentParser(description='Create a file with the environment variables')
    parser.add_argument('-o', '--output', help='output path')
    args = parser.parse_args(argv)
    
    json_str = ''
    for line in sys.stdin:
        json_str += line

    print json_str

    json_vars = json.loads(json_str)

    with open(args.output, 'w') as f:
        for k,v in json_vars.iteritems():
            f.write(k + '=' + v + '\n')

    print 'Wrote env file to ' + args.output

if __name__ == "__main__":
    main(sys.argv[1:])

