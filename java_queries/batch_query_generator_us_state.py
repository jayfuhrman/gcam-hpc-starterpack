#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 26 2021
@author: jay/shreekar
"""


#This file along with the batch_query_templates directory and its contents should be copied to the top level of [gcam-core]/output/queries

query_strs = ['CO2 emissions by sector',
              'CO2 emissions by sector (no bio)',
              'CO2 emissions by assigned sector (no bio)',
              'CO2 emissions by subsector',
              'CO2 emissions by tech',
              'CO2 sequestration by sector',
              'CO2 sequestration by tech',
              'policy cost by period',
              'undiscounted policy cost',
              'regional CO2 MAC curves by period',
              'prices of all markets',
              'supply of all markets',
              'demand of all markets',
              'inputs by sector'              ,
              'inputs by subsector',
              'inputs by tech',
              'outputs by sector'              ,
              'outputs by subsector',
              'outputs by tech',
              'elec gen by subsector',
              'elec gen by gen tech',
              'elec energy input by subsector',
              'elec energy input by elec gen tech',
              'elec prices by sector',
              'elec gen costs by subsector',
              'elec gen costs by tech',
              'refined liquids production by tech',
              'refinery inputs by tech (energy and feedstocks)',
              'refined liquids prices by sector',
              'refined liquids costs by tech',
              'total final energy by aggregate sector',
              'detailed land allocation',
              'land allocation by crop',
              'aggregated land allocation',
              'land allocation by crop and water source',
              'profit rate',
              'purpose-grown biomass production',
              'residue biomass production',
              'MSW production',
              'demand balances by crop commodity',
              'building final energy by tech',
              'building service output by tech',
              'building floorspace',
              'industry final energy by service and fuel',
              'transport final energy by tech and fuel',
              'transport final energy by tech (new)',
              'transport service output by tech',
              'transport service output by tech (new)',
              'CO2 emissions by region',
              'population by region',
              'GDP MER by region',
              'GDP per capita MER by region',
              'GDP per capita PPP by region',
              'CO2 prices',
              'water consumption by region',
              'water withdrawals by region',
              'elec gen by region (incl CHP)',
              'refined liquids production by region',
              'primary energy consumption by region (direct equivalent)',
              'primary energy consumption by region (avg fossil efficiency)',
              'primary energy consumption with CCS by region (direct equivalent)',
              'LUC emissions by region',
              'LUC emissions by LUT',
              'regional biomass consumption',
              'primary energy consumption with CCS by region (direct equivalent)'
              ]

gcam_global=['USA',
              'Africa_Eastern',
              'Africa_Northern',
              'Africa_Southern',
              'Africa_Western',
              'Australia_NZ',
              'Brazil',
              'Canada',
              'Central America and Caribbean',
              'Central Asia',
              'China',
              'EU-12',
              'EU-15',
              'Europe_Eastern',
              'Europe_Non_EU',
              'European Free Trade Association',
              'India',
              'Indonesia',
              'Japan',
              'Mexico',
              'Middle East',
              'Pakistan',
              'Russia',
              'South Africa',
              'South America_Northern',
              'South America_Southern',
              'South Asia',
              'South Korea',
              'Southeast Asia',
              'Taiwan',
              'Argentina',
              'Colombia']

gcam_states = ['AK', 'AL', 'AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL',
              'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA',
              'MD', 'ME', 'MI', 'MN', 'MO', 'MS', 'MT', 'NC', 'ND', 'NE',
              'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'RI',
              'SC', 'SD', 'TN', 'TX', 'UT', 'VA', 'VT', 'WA', 'WI', 'WV',
              'WY']

gcam_regions = gcam_states + gcam_global

def create_query_files(query_strs,states):
    "this function will create the xml files required to configure and write a batch query to csv files for n parallel runs of GCAM."  
    "The query_str input should be copied from one of the 'title' attributes from the Main_queries_template.xml file"
    import xml.etree.ElementTree as ET
    #import numpy as np

    if states==False:
        for query_str in query_strs:
            
            path = query_str.replace(" ","_")
            path = path.replace("(","")
            path = path.replace(")","")
            path = path+'_global'
#            path = path+'_global'            
            
            all_queries = ET.parse('batch_query_templates/Main_queries.xml')
            #all_queries_root = all_queries.getroot()
            
            #ET.dump(all_queries_root)
            
            
            xpath = './/*[@title=\''+query_str+'\']'
            
            #print(xpath)
            
            query = all_queries.findall(xpath)[0]
            
            
            
            query_template = ET.parse('batch_query_templates/query_template_global.xml')
            query_template_root = query_template.getroot()
            
            aquery = query_template_root.findall("aQuery")[0]
            aquery.insert(1,query)
            
            
            
            query_folder = 'output/queries/'
            query_file = 'query_'+path+'.xml'
            query_template.write(query_folder+query_file)

##UPto here query should be built.            
##Below construct xmldb batch files            
            #
            xmldb_batch = ET.parse('batch_query_templates/xmldb_batch_template_global.xml')
            xmldb_batch_root = xmldb_batch.getroot()
            
            
            #ET.dump(xmldb_batch_root)
            queryFile_path = xmldb_batch_root.findall(".//*queryFile")[0]
            outFile_path = xmldb_batch_root.findall(".//*outFile")[0]
            
            
            query_folder = 'output/queries/'
            queryFile_path.text = query_folder+query_file
            outFile_path.text = 'queryout_'+path+'.csv'
            
            xmldb_pointer_folder = 'exe/'
            xmldb_pointer_file = 'xmldb_batch_'+path+'.xml'
            
            xmldb_batch.write(xmldb_pointer_folder+xmldb_pointer_file)
            #print('Done creating xml file. Please copy the following bash code into the run_model.sh file:')
            print('java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/'+xmldb_pointer_file)
            print('')
            
            #print('If running query on an already-completed GCAM run, set the TARGETFILE and QUERYFILE as follows before running the postproc_scratch.sh script:')
            #print('TARGETFILE='+xmldb_pointer_file)
            #print('QUERYFILE='+query_file)
    else:
##US states + GCAM 32 regions + Global region
        for query_str in query_strs:
            
            path = query_str.replace(" ","_")
            path = path.replace("(","")
            path = path.replace(")","")
            path = path+'_states'
            
            
            all_queries = ET.parse('batch_query_templates/Main_queries.xml')
            #all_queries_root = all_queries.getroot()
            
            #ET.dump(all_queries_root)
            
            
            xpath = './/*[@title=\''+query_str+'\']'
            
            #print(xpath)
            
            query = all_queries.findall(xpath)[0]
            
            
            
            query_template = ET.parse('batch_query_templates/query_template_global.xml')
            query_template_root = query_template.getroot()
            
            aQuery = query_template_root.find('aQuery')
            query_template_root.remove(aQuery)
            

            #aquery = query_template_root.findall("aQuery")[0]
            #aquery.insert(1,query)
            aquery = ET.SubElement(query_template_root,'aQuery')
            reg = ET.SubElement(aquery,'region',attrib={'name':'Global'})
            aquery.insert(1,query)

            for i in range(len(gcam_regions)):
                aquery = ET.SubElement(query_template_root,'aQuery')
                reg = ET.SubElement(aquery,'region',attrib={'name':gcam_regions[i]})
                aquery.insert(1,query)
                
                

            query_folder = 'output/queries/'
            query_file = 'query_'+path+'.xml'
            
            query_template.write(query_folder+query_file)
            #print('Done writing query file')
            
            #
            xmldb_batch = ET.parse('batch_query_templates/xmldb_batch_template_global.xml')
            xmldb_batch_root = xmldb_batch.getroot()
            
            
            #ET.dump(xmldb_batch_root)
            queryFile_path = xmldb_batch_root.findall(".//*queryFile")[0]
            outFile_path = xmldb_batch_root.findall(".//*outFile")[0]
            
            
            
            queryFile_path.text = query_folder+query_file
            outFile_path.text = 'queryout_'+path+'.csv'
            
            xmldb_pointer_folder = 'exe/'
            xmldb_pointer_file = 'xmldb_batch_'+path+'.xml'
            
            xmldb_batch.write(xmldb_pointer_folder+xmldb_pointer_file)
            #print('Done creating pointer file. Please copy the following bash code into the run_model.sh file:')
            print('java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/'+xmldb_pointer_file)
            #print('')
            
            #print('If running query on an already-completed GCAM run, set the TARGETFILE and QUERYFILE as follows before running the postproc_scratch.sh script:')
            #print('TARGETFILE='+xmldb_pointer_file)
            #print('QUERYFILE='+query_file)
        
    

create_query_files(query_strs,False)    