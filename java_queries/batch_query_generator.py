#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri May 10 10:49:32 2019

@author: jgf5fz
"""




query_strs = ['CO2 emissions by tech'] #change this string to create the query

gcam_regions=['USA',
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



def create_query_files(query_strs,disaggregated):
    "this function will create the xml files required to configure and write a batch query to csv files for n parallel runs of GCAM.  The query_str input should be copied from one of the 'title' attributes from the Main_queries_template.xml file"
    import xml.etree.ElementTree as ET
    import numpy as np

    if disaggregated==False:
        for query_str in query_strs:
            
            path = query_str.replace(" ","_")
            path = path.replace("(","")
            path = path.replace(")","")
            path = path+'_global'
            
            
            all_queries = ET.parse('batch_query_templates/Main_queries_template.xml')
            #all_queries_root = all_queries.getroot()
            
            #ET.dump(all_queries_root)
            
            
            xpath = './/*[@title=\''+query_str+'\']'
            
            #print(xpath)
            
            query = all_queries.findall(xpath)[0]
            
            
            
            query_template = ET.parse('batch_query_templates/query_template_global.xml')
            query_template_root = query_template.getroot()
            
            aquery = query_template_root.findall("aQuery")[0]
            aquery.insert(1,query)
            
            
            
            query_folder = '../../gcam_5_3/output/queries/'
            query_file = 'query_'+path+'.xml'
            query_template.write(query_folder+query_file)
            
            
            #
            xmldb_batch = ET.parse('batch_query_templates/xmldb_batch_template_global.xml')
            xmldb_batch_root = xmldb_batch.getroot()
            
            
            #ET.dump(xmldb_batch_root)
            queryFile_path = xmldb_batch_root.findall(".//*queryFile")[0]
            outFile_path = xmldb_batch_root.findall(".//*outFile")[0]
            
            
            query_folder = '../output/queries/'
            queryFile_path.text = query_folder+query_file
            outFile_path.text = 'queryout_'+path+'.csv'
            
            xmldb_pointer_folder = '../../gcam_5_3/exe/'
            xmldb_pointer_file = 'xmldb_batch_'+path+'.xml'
            
            xmldb_batch.write(xmldb_pointer_folder+xmldb_pointer_file)
            print('Done creating xml file. Please copy the following bash code into the run_model.sh file:')
            print('java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/'+xmldb_pointer_file)
            print('')
            
            print('If running query on an already-completed GCAM run, set the TARGETFILE and QUERYFILE as follows before running the postproc_scratch.sh script:')
            print('TARGETFILE='+xmldb_pointer_file)
            print('QUERYFILE='+query_file)
    else:
        for query_str in query_strs:
            
            path = query_str.replace(" ","_")
            path = path.replace("(","")
            path = path.replace(")","")
            path = path+'_regionalized'
            
            
            all_queries = ET.parse('batch_query_templates/Main_queries_template.xml')
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
                
                

            query_folder = '../output/queries/'
            query_file = 'query_'+path+'.xml'
            
            query_template.write(query_folder+query_file)
            print('Done writing query file')
            
            #
            xmldb_batch = ET.parse('batch_query_templates/xmldb_batch_template_global.xml')
            xmldb_batch_root = xmldb_batch.getroot()
            
            
            #ET.dump(xmldb_batch_root)
            queryFile_path = xmldb_batch_root.findall(".//*queryFile")[0]
            outFile_path = xmldb_batch_root.findall(".//*outFile")[0]
            
            
            
            queryFile_path.text = query_folder+query_file
            outFile_path.text = 'queryout_'+path+'.csv'
            
            xmldb_pointer_folder = '../../gcam_5_3/exe'
            xmldb_pointer_file = 'xmldb_batch_'+path+'.xml'
            
            xmldb_batch.write(xmldb_pointer_folder+xmldb_pointer_file)
            print('Done creating pointer file. Please copy the following bash code into the run_model.sh file:')
            print('java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/'+xmldb_pointer_file)
            print('')
            
            print('If running query on an already-completed GCAM run, set the TARGETFILE and QUERYFILE as follows before running the postproc_scratch.sh script:')
            print('TARGETFILE='+xmldb_pointer_file)
            print('QUERYFILE='+query_file)
        
    

create_query_files(query_strs,False)    
    
