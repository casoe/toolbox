#!/usr/bin/python
#Author: Jan-Michael Regulski
#File: FileSplitterByField.py
#Erstellungsdatum: 04.10.2019
#Purpose: Grouping the data of a CSV file into separate files by a given field and grouping type.
#Version info: 0.1


import sys
import os
import csv
import re
import pandas as pd
import numpy as np

class FileSplitter:

    def __init__(self):
        self.parse_args(sys.argv)

    @staticmethod
    def run():
        splitter = FileSplitter()
        splitter.split()

    def split(self):

        try:
            df = pd.read_csv(self.in_file, sep=';', engine='python');

            for item in range(0, len(df.index)):
                try:
            
                    write_header = True;
                    new_df = pd.DataFrame(df.loc[item:item]);
                    if self.group_type == "date":
                        new_df[self.field_name] = pd.to_datetime(new_df[self.field_name],errors='coerce', dayfirst=True);
                        str_rpl = self.file_base_name + "_" + str(new_df[self.field_name].dt.year.values) + "-" + str(new_df[self.field_name].dt.month.values) + self.file_ext;
                        new_file_name = self.get_valid_filename(str_rpl); # serve for valid file name
                    elif self.group_type == "string":
                        str_rpl = self.file_base_name + "-" + str(new_df[self.field_name].values) + self.file_ext;
                        new_file_name = self.get_valid_filename(str_rpl); # serve for valid file name
                    else:
                        print (self.usage());
                        sys.exit(1);
                    new_file_path = os.path.join(self.file_dir, new_file_name);
                except Exception as e:
                    print("Error: Problem with analyzing data of input file '" + str(self.file_name) + "': " + str(e));
                    sys.exit(1);
          
                try:
                    if os.path.isfile(new_file_path):
                        write_header = False;
                    else:
                        write_header = True;
                    new_file = open(new_file_path, "a+");
                    df.loc[item:item].to_csv(new_file,sep=";",decimal=",",index=False, header=write_header, line_terminator="\n")
                    new_file.close();
                except Exception as e:
                    print("Error: Problem with new file '" + new_file_path + "' during creation, writing or closing: " + str(e));
                    sys.exit(1);
        except Exception as e:
            print("Error: Problem with reading csv data of input file '" + str(self.file_name) + "': " + str(e));
            sys.exit(1);

    def get_valid_filename(self, s):
        s = str(s).strip().replace(' ', '_')
        return re.sub(r'(?u)[^-\w.]', '', s)

    def parse_args(self,argv):
        """parse args and set up instance variables"""
        try:
            self.group_type = "string"
            if len(argv) > 3:
                self.group_type = argv[3]
            self.file_name = argv[1]
            self.field_name = argv[2]
        except:
            print (self.usage())
            sys.exit(1)
        try:
            self.in_file = open(self.file_name, "r", encoding="ISO-8859-1")
            self.working_dir = os.getcwd()
            self.file_base_name, self.file_ext = os.path.splitext(self.file_name)
            self.file_path = os.path.realpath(self.file_name)
            self.file_dir = os.path.dirname(self.file_path)
        except Exception as e:
          print("Error: Input file '" + self.file_name + "' not available." + str(e));
          sys.exit(1)

    def usage(self):
        return """
        Grouping the data of a CSV file into separate files by a given field and grouping type.
        - date: group by month and year
        - string: group by field content
        Usage:
            $ python FilesSlitterByField.py <file_name> <field_name> <grouping_type>
        """

if __name__ == "__main__":
    FileSplitter.run()