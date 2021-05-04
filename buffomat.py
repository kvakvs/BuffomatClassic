#!/usr/bin/env python3
#
# Buffomat Release and Install tool
#

import argparse
import os
import shutil
import subprocess
import sys
import zipfile

BOM_VERSION = '2021.5.2'  # year.month.build_num
UI_VERSION_CLASSIC = '11307'  # patch 1.13.7
UI_VERSION_CLASSIC_TBC = '20501'  # patch 2.5.1
BOM_NAME_CLASSIC = 'BuffomatClassic'
BOM_NAME_CLASSIC_TBC = 'BuffomatClassicTBC'
COPY_DIRS = ['src', 'const']
COPY_FILES = ['Bindings.xml', 'Bom.lua', 'Bom.xml', 'CHANGELOG.md',
              'LICENSE.txt', 'README.md', 'README.Deutsch.txt']


class BuildTool:
    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.version = BOM_VERSION
        self.copy_dirs = COPY_DIRS[:]
        self.copy_files = COPY_FILES[:]
        self.create_toc(f'{BOM_NAME_CLASSIC}.toc', UI_VERSION_CLASSIC)
        self.create_toc(f'{BOM_NAME_CLASSIC_TBC}.toc', UI_VERSION_CLASSIC_TBC)

    def do_install(self, toc_name: str):
        self.copy_files.append(f'{toc_name}.toc')
        dst_path = f'{self.args.dst}/{toc_name}'

        if os.path.isdir(dst_path):
            print("Warning: Folder already exists, removing!")
            shutil.rmtree(dst_path)

        os.makedirs(dst_path, exist_ok=True)

        print(f'Destination: {dst_path}')

        for copy_dir in self.copy_dirs:
            print(f'Copying directory: {copy_dir}/*')
            shutil.copytree(copy_dir, f'{dst_path}/{copy_dir}')

        for copy_file in self.copy_files:
            print(f'Copying: {copy_file}')
            shutil.copy(copy_file, f'{dst_path}/{copy_file}')

    @staticmethod
    def do_zip_add_dir(zip: zipfile.ZipFile, dir: str, toc_name: str):
        for file in os.listdir(dir):
            file = dir + "/" + file
            print(f'ZIP: Directory {file}/')
            if os.path.isdir(file):
                BuildTool.do_zip_add_dir(zip,
                                         dir=file,
                                         toc_name=toc_name)
            else:
                zip.write(file, f'{toc_name}/{file}')

    def do_zip(self, toc_name: str):
        self.copy_files.append(f'{toc_name}.toc')
        zip_name = f'{self.args.dst}/{toc_name}-{self.version}.zip'

        with zipfile.ZipFile(zip_name, "w", zipfile.ZIP_DEFLATED,
                             allowZip64=True) as zip_file:
            for input_dir in self.copy_dirs:
                BuildTool.do_zip_add_dir(zip_file,
                                         dir=input_dir,
                                         toc_name=toc_name)

            for input_f in self.copy_files:
                print(f'ZIP: File {input_f}')
                zip_file.write(input_f, f'{toc_name}/{input_f}')

    @staticmethod
    def git_hash() -> str:
        # Call: git rev-parse HEAD
        p = subprocess.check_output(
            ["git", "rev-parse", "HEAD"])
        hash = str(p).rstrip("\\n'").lstrip("b'")
        return hash[:8]

    def create_toc(self, dst: str, ui_version: str):
        hash = BuildTool.git_hash()

        template = open('toc_template.toc', "rt").read()
        template = template.replace('${UI_VERSION}', ui_version)
        template = template.replace('${BOM_VERSION}', f'{BOM_VERSION}-{hash}')

        with open(dst, "wt") as out_f:
            out_f.write(template)


def main():
    parser = argparse.ArgumentParser(
        description="Buffomat Release and Install tool")
    parser.add_argument(
        '--dst', type=str, required=True, action='store',
        help='The destination directory where the game Addons will be copied, '
             'or where ZIP will be stored. TOC name will serve as directory '
             'name.')

    parser.add_argument(
        '--version', choices=['classic', 'tbc'],
        help='The version to copy or zip, classic or TBC')

    parser.add_argument(
        'command', choices=['help', 'zip', 'install'],
        help='The action to take. ZIP will create an archive. '
             'Install will copy')

    args = parser.parse_args(sys.argv[1:])
    print(args)

    if args.command == 'install':
        bt = BuildTool(args)
        if args.version == 'classic':
            bt.do_install(toc_name=BOM_NAME_CLASSIC)
        else:
            bt.do_install(toc_name=BOM_NAME_CLASSIC_TBC)

    elif args.command == 'zip':
        bt = BuildTool(args)
        if args.version == 'classic':
            bt.do_zip(toc_name=BOM_NAME_CLASSIC)
        else:
            bt.do_zip(toc_name=BOM_NAME_CLASSIC_TBC)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
