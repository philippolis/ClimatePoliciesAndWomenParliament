import csv

# Data stems from the Climate Change Performance Index 2020 and was retrieved from
# https://github.com/dbabbs/climate-change-performance-index-map/blob/master/src/data/data.js

toCSV = [
   { 'name': 'Sweden', 'value': 75.77, 'code': 'SWE' },
   { 'name': 'Denmark', 'value': 71.14, 'code': 'DNK' },
   { 'name': 'Morocco', 'value': 70.63, 'code': 'MAR' },
   { 'name': 'United Kingdom', 'value': 69.8, 'code': 'GBR' },
   { 'name': 'Lithuania', 'value': 66.22, 'code': 'LTU' },
   { 'name': 'India', 'value': 66.02, 'code': 'IND' },
   { 'name': 'Finland', 'value': 63.25, 'code': 'FIN' },
   { 'name': 'Chile', 'value': 62.88, 'code': 'CHL' },
   { 'name': 'Norway', 'value': 61.14, 'code': 'NOR' },
   { 'name': 'Luxembourg', 'value': 60.91, 'code': 'LUX' },
   { 'name': 'Malta', 'value': 60.76, 'code': 'MLT' },
   { 'name': 'Latvia', 'value': 60.75, 'code': 'LVA' },
   { 'name': 'Switzerland', 'value': 60.61, 'code': 'CHE' },
   { 'name': 'Ukraine', 'value': 60.6, 'code': 'UKR' },
   { 'name': 'France', 'value': 57.9, 'code': 'FRA' },
   { 'name': 'Egypt', 'value': 57.53, 'code': 'EGY' },
   { 'name': 'Croatia', 'value': 56.97, 'code': 'HRV' },
   { 'name': 'Brazil', 'value': 55.82, 'code': 'BRA' },
   { 'name': 'Germany', 'value': 55.78, 'code': 'DEU' },
   { 'name': 'Romania', 'value': 54.85, 'code': 'ROU' },
   { 'name': 'Portugal', 'value': 54.1, 'code': 'PRT' },
   { 'name': 'Italy', 'value': 53.92, 'code': 'ITA' },
   { 'name': 'Slovakia', 'value': 52.69, 'code': 'SVK' },
   { 'name': 'Greece', 'value': 52.59, 'code': 'GRC' },
   { 'name': 'Netherlands', 'value': 50.89, 'code': 'NLD' },
   { 'name': 'China', 'value': 48.16, 'code': 'CHN' },
   { 'name': 'Estonia', 'value': 48.05, 'code': 'EST' },
   { 'name': 'Mexico', 'value': 47.01, 'code': 'MEX' },
   { 'name': 'Thailand', 'value': 46.76, 'code': 'THA' },
   { 'name': 'Spain', 'value': 46.03, 'code': 'ESP' },
   { 'name': 'Belgium', 'value': 45.73, 'code': 'BEL' },
   { 'name': 'South Africa', 'value': 45.67, 'code': 'ZAF' },
   { 'name': 'New Zealand', 'value': 45.67, 'code': 'NZL' },
   { 'name': 'Austria', 'value': 44.74, 'code': 'AUT' },
   { 'name': 'Indonesia', 'value': 44.65, 'code': 'IDN' },
   { 'name': 'Belarus', 'value': 44.18, 'code': 'BLR' },
   { 'name': 'Ireland', 'value': 44.04, 'code': 'IRL' },
   { 'name': 'Argentina', 'value': 43.77, 'code': 'ARG' },
   { 'name': 'Czech Republic', 'value': 42.93, 'code': 'CZE' },
   { 'name': 'Slovenia', 'value': 41.91, 'code': 'SVN' },
   { 'name': 'Cyprus', 'value': 41.66, 'code': 'CYP' },
   { 'name': 'Algeria', 'value': 41.45, 'code': 'DZA' },
   { 'name': 'Hungary', 'value': 41.17, 'code': 'HUN' },
   { 'name': 'Turkey', 'value': 40.7, 'code': 'TUR' },
   { 'name': 'Bulgaria', 'value': 40.12, 'code': 'BGR' },
   { 'name': 'Poland', 'value': 39.98, 'code': 'POL' },
   { 'name': 'Japan', 'value': 39.03, 'code': 'JPN' },
   { 'name': 'Russia', 'value': 37.85, 'code': 'RUS' },
   { 'name': 'Malaysia', 'value': 34.21, 'code': 'MYS' },
   { 'name': 'Kazakhstan', 'value': 33.39, 'code': 'KAZ' },
   { 'name': 'Canada', 'value': 31.01, 'code': 'CAN' },
   { 'name': 'Australia', 'value': 30.75, 'code': 'AUS' },
   { 'name': 'Iran', 'value': 28.41, 'code': 'IRN' },
   { 'name': 'South Korea', 'value': 26.75, 'code': 'KOR' },
   { 'name': 'Taiwan', 'value': 23.33, 'code': 'TWN' },
   { 'name': 'Saudi Arabia', 'value': 22.03, 'code': 'SAU' },
   { 'name': 'United States', 'value': 18.6, 'code': 'USA' }
]

# Writing the data into a csv-file
keys = toCSV[0].keys()
with open('ClimatePolicyIndex.csv', 'w', newline='')  as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(toCSV)
    
    
