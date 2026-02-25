# Node-level commodity balance plots
# This script reads the flow results and creates mirrored stacked area charts for each node.

path = "C:\\Users\\kaush\\Downloads\\elec-h2\\results_002\\results\\flows.csv"
xlims = (4000, 4050) # First week of February

# Define your mapping
my_node = "elec_bal"
supply = ["wind_elec", "SolarPV_elec", "ng_ccgt_01_elec","LiIon_elec_discharge","MetalAir_elec_discharge"]
demand = ["GH2_elec", "smr_h2_elec"]

# Plot 
p = plot_node_balance(path, my_node, supply, demand, xlims)
display(p)

# Aggregate all plots
#p = plot(p_co2, p_elec, p_h2, layout=(3,1), size=(1000, 1200))