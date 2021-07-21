#!/bin/bash

module purge
module load gcc/7.1.0
module load intel/20.0
module load intelmpi/20.0
module load eigen/3.4-rc1
module load boost
module load xerces
module load java
#
#module load R


# Script expects two parameters: the configuration filename and the task number
# Filename should be the base name, not including job number or extension

CONFIGURATION_FILE=${1}_${2}.xml

GCAMDIR=/home/cff2aa/GCAM-core
SCRATCHDIR=/sfs/lustre/bahamut/scratch/cff2aa

cp ${GCAMDIR}/configuration-sets/run_set_documentation.txt ${SCRATCHDIR}
echo "copied run set documentation to scratch"

if [ ! -e $CONFIGURATION_FILE ]; then
	echo "$CONFIGURATION_FILE does not exist; task $2 bailing!"
	exit 
fi

echo "Configuration file: $CONFIGURATION_FILE"

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/homes/pralitp/libs/dbxml-2.5.16/install/lib

# It turns out that to pass data from C++ to Fortran, MiniCAM writes out a 'gas.emk' file
# which is then read in by MAGICC.  This is not good, as multiple instances will stomp
# all over each other.  The long-term solution is to pass internally; for now, we'll 
# create separate exe directories, even though this is a performance hit.


#rm -rf exe_$2	 	# just in case
#cp -fR exe exe_$2
#cd exe_$2

rm -rf ${SCRATCHDIR}/exe_$2	 	# just in case
#mkdir ${SCRATCHDIR}/exe_$2
cp -fR ${GCAMDIR}/exe ${SCRATCHDIR}/exe_$2
cd ${SCRATCHDIR}/exe_$2



echo "Running Minicam with ${CONFIGURATION_FILE}..."
# let's keep a copy of config file in the running directory
cp ${GCAMDIR}/$CONFIGURATION_FILE ./config_this.xml

chmod 2775 gcam.exe

echo "Starting gcam"
./gcam.exe -C${GCAMDIR}/$CONFIGURATION_FILE > output_${2}.txt 
err=$?


######Batch query specifications

echo "starting model interface.jar and reading batch queries"

#global queries
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_ag_commodity_prices_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_ag_commodity_prices_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_ag_commodity_prices_USA.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_ag_production_by_crop_type_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_ag_production_by_subsector_land_use_region_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_aggregated_land_allocation_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_biophysical_water_demand_by_ag_tech_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_biophysical_water_demand_by_crop_type_and_land_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_biophysical_water_demand_by_crop_type_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_biophysical_water_demand_by_region_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_co2_concentrations_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_co2_emissions_by_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_sector_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_sector_no_bio_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_sector_no_bio_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_co2_prices_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_prices_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_co2_seq_by_sector_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_co2_seq_by_tech_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_sequestration_by_sector_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_sequestration_by_tech_regionalized.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_costs_by_tech_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_costs_of_transport_techs_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_demand_of_all_markets_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_detailed_land_allocation_regionalized.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_gen_by_gen_tech_and_cooling_tech_and_vintage_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_gen_by_region_incl_CHP_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_share-weights_by_subsector_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_share-weights_by_subsector_regionalized.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_fertilizer_consumption_by_ag_tech_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_fertilizer_consumption_by_crop_type_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_final_energy_consumption_by_fuel_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_final_energy_consumption_by_sector_and_fuel_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_final_energy_consumption_by_sector_and_fuel_regionalized.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_GDP_MER_by_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_GDP_per_capita_MER_by_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_GDP_per_capita_PPP_by_region_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_global_mean_temperature_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_inputs_by_tech_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_irrigation_water_consumption_by_crop_type_and_land_region_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_irrigation_water_withdrawals_by_crop_type_and_land_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_irrigation_water_withdrawals_by_crop_type_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_land_allocation_by_crop_and_water_source_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_land_allocation_by_crop_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_land_allocation_in_a_specified_land_use_region_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_LUC_emissions_by_LUT_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_LUC_emissions_by_LUT_in_a_specified_land_use_region_VA_GLUs_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_LUC_emissions_by_region_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_mean_temperature_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_net_terrestrial_C_uptake_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_nonCO2_emissions_by_resource_production_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_nonCO2_emissions_by_sector_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_nonCO2_emissions_by_sector_regionalized.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_outputs_by_sector_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_outputs_by_sector_regionalized.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_outputs_by_tech_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_population_by_region_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_prices_by_sector_global.xm
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_prices_of_all_markets_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_primary_energy_consumption_by_region_avg_fossil_efficiency_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_primary_energy_consumption_by_region_direct_equivalent_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_primary_energy_consumption_with_CCS_by_region_direct_equivalent_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_primary_energy_consumption_with_CCS_by_region_direct_equivalent_regionalized.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_profit_rate_in_a_specified_land_use_region_VA_GLUs_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_refined_liquids_production_by_region_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_regional_biomass_consumption_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_resource_production_regionalized.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_supply_of_all_markets_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_total_final_energy_by_sector_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_transport_service_output_by_tech_global.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_water_consumption_by_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_water_consumption_by_sector_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_water_withdrawals_by_region_global.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_water_withdrawals_by_sector_global.xml


#states queries
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_aggregated_land_allocation_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_building_final_energy_by_tech_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_building_floorspace_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_building_service_output_by_tech_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_assigned_sector_no_bio_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_region_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_sector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_sector_no_bio_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_subsector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_emissions_by_tech_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_prices_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_sequestration_by_sector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_CO2_sequestration_by_tech_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_demand_balances_by_crop_commodity_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_demand_of_all_markets_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_detailed_land_allocation_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_energy_input_by_subsector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_energy_input_by_elec_gen_tech_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_gen_by_gen_tech_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_gen_by_region_incl_CHP_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_gen_by_subsector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_gen_costs_by_subsector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_gen_costs_by_tech_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_elec_prices_by_sector_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_GDP_MER_by_region_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_GDP_per_capita_MER_by_region_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_GDP_per_capita_PPP_by_region_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_industry_final_energy_by_service_and_fuel_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_inputs_by_sector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_inputs_by_subsector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_inputs_by_tech_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_land_allocation_by_crop_and_water_source_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_land_allocation_by_crop_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_LUC_emissions_by_LUT_in_a_specified_land_use_region_VA_GLUs_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_LUC_emissions_by_LUT_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_LUC_emissions_by_region_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_MSW_production_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_outputs_by_sector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_outputs_by_subsector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_outputs_by_tech_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_policy_cost_by_period_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_population_by_region_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_prices_of_all_markets_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_primary_energy_consumption_by_region_avg_fossil_efficiency_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_primary_energy_consumption_by_region_direct_equivalent_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_primary_energy_consumption_with_CCS_by_region_direct_equivalent_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_profit_rate_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_purpose-grown_biomass_production_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_refined_liquids_costs_by_tech_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_refined_liquids_prices_by_sector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_refined_liquids_production_by_region_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_refined_liquids_production_by_tech_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_refinery_inputs_by_tech_energy_and_feedstocks_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_regional_biomass_consumption_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_regional_CO2_MAC_curves_by_period_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_residue_biomass_production_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_supply_of_all_markets_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_total_final_energy_by_aggregate_sector_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_transport_final_energy_by_tech_and_fuel_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_transport_final_energy_by_tech_new_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_undiscounted_policy_cost_states.xml

java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_water_consumption_by_region_states.xml
java ModelInterface.InterfaceMain -b ${SCRATCHDIR}/exe_$2/xmldb_batch_water_withdrawals_by_region_states.xml


echo "done reading batch query files"


chmod 2775 -R ${SCRATCHDIR}/exe_$2

if [[ $err -gt 0 ]]; then
	echo "Error code reported: $err"
	echo $err > ${SCRATCHDIR}/errors/$2
else
	#cp batchout_${2}.csv ../output/
	#cp magout_c.csv ../output/magout_${2}.csv
        # cp gas.emk ../output/gas_${2}.emk
         cp gas.emk ${SCRATCHDIR}/output/gas_${2}.emk
	#cp database.dbxml ../output/database_${2}.dbxml
    #Xvfb :$2 -pn -audit 4 -screen 0 800x600x16 &
    #export DISPLAY=:${2}.0
    #java -jar /homes/pralitp/ModelInterface/ModelInterface.jar -b xmldb_batch.xml


	#cd ..
	#rm -rf ${SCRATCH}/exe_$2
fi

echo "Task $2 is done!"

# return $err

