#!/usr/bin/python
#Author: Jan-Michael Regulski
#File: GroupInvocesByNumber.py
#Erstellungsdatum: 13.11.2019
#Purpose: Group and aggregate data by invoice number to find payed and partly payed invoices
#Version info: 0.2

# Aenderungen:
# 2022.01:
# - Fehlerbehebung: Summation von Betrag Soll, beruecksichtigt damit mehrere Forderungsbetraege pro Rechnung
# - Fehlerbehebung: Zahlungsdatum vor Rechnungsdatum (Saldo wird jetzt vor Filterung ermittelt und Zahldatum nur ueber Reihen mit Betrag Haben-Wert)
# - Gegenkonto mit zusaetzlicher 0 am Ende (feste Werte ergaenzt)

import sys
import os
import csv
import re
import pandas as pd
import numpy as np

class GroupInvoices:

    def __init__(self):
        self.parse_args(sys.argv)

    @staticmethod
    def run():
        grouper = GroupInvoices()
        grouper.group()



    def group(self):

        ErlaubteZusatzkonten = [136400,215000,221900,266000]
    
        def removeNumberSign(field):
          field = field.replace(",", "")
          return field.replace(".", "")
        def deleteSpacesADiv(field):
          field = field.replace("div.", "-1")
          return field.replace(" ", "")
        def setDash(field):
          if field == "":
            field = "-"
          return field
          
        try:
            #Einlesen, formatieren, erweitern und filtern der Daten
            fields = ["Rechnungs-Nr.","Datum","Saldo","Gegenkonto", "S/H Saldo", "Betrag Soll", "Betrag Haben",]
            df = pd.read_csv(self.in_file, engine='python', encoding='utf8', sep=';', decimal=".", skipinitialspace=True, usecols=fields, skiprows=1, converters={fields[3]: deleteSpacesADiv, fields[4]: setDash});
            df.fillna(0, inplace=True)
            df[fields[0]] = df[fields[0]].astype(str)#hier gibt es ggf. auch andere Strings
            #df[fields[1]] = pd.to_datetime(df[fields[1]],format='%d.%m.%Y')
            df[fields[2]] = pd.to_numeric(df[fields[2]])#Auf numerisch setzen
            df[fields[3]] = pd.to_numeric(df[fields[3]])#Auf numerisch setzen
            df[fields[4]] = df[fields[4]].astype(str)
            df[fields[5]] = pd.to_numeric(df[fields[5]])#Auf numerisch setzen
            df[fields[6]] = pd.to_numeric(df[fields[6]])#Auf numerisch setzen
            df = df[df[fields[4]] != "H"]# Ausfiltern von allen H-Zeilen (Guthaben), H-Saldi werden dadurch genullt

            #Gruppieren auf Rechnungsnr, um Betrag Soll und Saldo zu erhalten (weil sonst unten ueber Gegenkonto herausgefiltert)
            Group = df.groupby(fields[0])#Aggregation pro Rechnungsnummer
            #df2 = Group[fields[5]].agg([np.max])#alt: Dataframe mit allen Zahlbetraegen
            df2 = Group[fields[5]].agg([np.sum])#Dataframe mit Summe aller Soll-Zahlbetraegen
            df2.columns = ['Betrag Soll Sum']
            df21 = Group[fields[2]].agg([np.amax])#Dataframe mit Saldowert, sollte nur einer sein
            df21.columns = ['Saldo Ori']
            df31 = pd.merge(df, df2, how='left', left_on=fields[0], right_index=True)#Neuer Dataframe mit allen Daten
            df3 = pd.merge(df31, df21, how='left', left_on=fields[0], right_index=True)#Neuer Dataframe mit allen Daten

            #Filtern auf Bank- und Zusatzkonten, dadurch nur Erfassung eingegangener Buchungen
            df3 = df3[(df3[fields[3]].isin(ErlaubteZusatzkonten) | ((df3[fields[3]] <= 129990) & (df3[fields[3]] >= 120000)))]

            #Gruppierung pro Rechnungsnummer fuer einmalige Ausgabe
            Group = df3.groupby(fields[0])
            #Saldo: bei 0 bezahlt, bei > 0 teilweise bezahlt (da Filterung auf Bankkonten war immer eine Zahlung da)
            data1 = Group['Saldo Ori'].agg([np.amax]) * 100#Saldo von oben 'runtergerettet', da sonst bei Zahlung vor Rechnung ausgefiltert
            #data1 = Group[fields[2]].agg([np.sum]) * 100 #alt: Saldo direkt
            data21 = df3[df3[fields[6]] != 0].groupby(fields[0])#Ausfiltern von leeren Betrag Haben-Spalten, um nur Reihen mit Zahlungen zu erhalten
            data2 = data21[fields[1]].agg([np.max,np.count_nonzero])#Letztes Datum als Zahldatum und Buchungsanzahl
            #data2 = Group[fields[1]].agg([np.amax,np.count_nonzero])#alt: Letztes Datum als Zahldatum und Buchungsanzahl
            data3 = Group["Betrag Soll Sum"].agg([np.amax]) * 100#Max. Betrag Soll als Zahlbetrag (Summe von oben)
            data4 = Group[fields[6]].agg([np.sum]) * 100#Summe aller Betrag-Haben-Werte
            datapre = pd.concat([data1,data2,data3,data4], axis=1)
            datapre.columns = ['Saldo', 'Zahldatum', 'Buchungsanzahl', 'Zahlbetrag', 'Teilzahlungen']
            data = datapre[datapre['Buchungsanzahl'] > 0]#herausfiltern von allen Zeilen ohne Zahlungsbuchung

        except Exception as e:
            print("Error: Problem with input file '" + str(self.file_name) + "' during opening or analyzing: " + str(e));
            sys.exit(1)

        try:
            data.to_csv(self.file_name_out, sep=';',index=True, decimal=",", float_format='%.0f')
        except Exception as e:
            print("Error: Problem with writing output file '" + str(self.file_name_out) + ": " + str(e));
            sys.exit(1)

            
    def get_valid_filename(self, s):
        s = str(s).strip().replace(' ', '_')
        return re.sub(r'(?u)[^-\w.]', '', s)

    def parse_args(self,argv):
        """parse args and set up instance variables"""
        try:
            self.file_name = argv[1]
            self.file_name_out = argv[2]
        except:
            print (self.usage())
            sys.exit(1)
        try:
            self.in_file = open(self.file_name, "r", encoding="utf8")
            self.working_dir = os.getcwd()
            self.file_base_name, self.file_ext = os.path.splitext(self.file_name)
        except Exception as e:
          print("Error: Input file '" + self.file_name + "' not available: " + str(e) )
          sys.exit(1)

    def usage(self):
        return """
        Groups a given CSV file and writes aggregations of certain fields to a given output file.
        Usage:
            $ python GroupInvoicesByNumber.py <file_name> <file_name_out>
        """

if __name__ == "__main__":
    GroupInvoices.run()