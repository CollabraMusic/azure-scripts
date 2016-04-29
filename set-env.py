#!/usr/bin/python

import sys, argparse, json

def main(argv):
    parser = argparse.ArgumentParser(description='Create a file with the environment variables')
    parser.add_argument('-j', '--json', help='JSON with the arguments')
    parser.add_argument('-o', '--output', help='output path')
    args = parser.parse_args(argv)
    
    json_vars = json.loads(args.json.decode('string_escape'))

    with open(args.output, 'w') as f:
        for k,v in json_vars.iteritems():
            f.write(k + '=' + v + '\n')

if __name__ == "__main__":
    main(sys.argv[1:])

