#!/usr/local/bin/python3
""" 
A tool to generate maps coming from RUTX installed in a van
"""
import argparse
import logging
import pandas as pd
import plotly.express as px


def main():
  """
  read a tab separated file containing the gps output and map it
  """

  parser = argparse.ArgumentParser(description="map a trace from a RUTX router")
  parser.add_argument("filename", metavar="<trace file>", help="a file containing a GPS trace in tabular formar to process")

  parser.add_argument("--verbose", "-v", help="activate verbose/debug mode", action="store_true", default=False)
  args = parser.parse_args()
  
  if args.verbose:
    log_level = logging.DEBUG
  else:
    log_level = logging.INFO

  logging.basicConfig(level=log_level)

  track = pd.read_csv(args.filename, sep='\t')

  token = open(".mapbox_token").read()
  print(token)

  fig = px.scatter_mapbox(track, lat='Latitude ', lon='Longitude ', color='Speed')
  fig.update_layout(mapbox_style='satellite-streets', mapbox_accesstoken=token)
  fig.show()
  fig.write_image(args.filename+".png", width=1024, height=768)
 

if __name__ == '__main__':
    main()
