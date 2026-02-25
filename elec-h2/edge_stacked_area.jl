using CSV
using DataFrames
using Plots

"""
    plot_commodity_flows(file_path, id_pattern, x_limits)

Automatically gathers columns matching "<id>_edge" and plots them.
- id_pattern: String or Regex (e.g., "elec" or "heat")
"""
function plot_commodity_flows(file_path::String, id_pattern::String, x_limits::Tuple{Number, Number})
    # 1. Load data
    df = CSV.read(file_path, DataFrame)
    
    # 2. Filter headers that contain the id_pattern AND end with "_edge"
    # This ignores the "time" column and other commodities
    all_headers = names(df)
    selected_cols = filter(h -> occursin(id_pattern, h) && endswith(h, "_edge"), all_headers)
    
    if isempty(selected_cols)
        error("No columns found matching pattern: $id_pattern")
    end

    # 3. Prepare data for plotting
    time_data = df.time
    plot_matrix = Matrix(df[:, selected_cols])
    
    # 4. Generate Plot
    p = areaplot(time_data, plot_matrix,
        labels = reshape(selected_cols, 1, :),
        xlims = x_limits,
        title = "Stacked Flows: $(uppercase(id_pattern))",
        xlabel = "Time (Hours)",
        ylabel = "Energy Flow (MW/Unit)",
        legend = :topright,
        fillalpha = 0.8,
        palette = :tab20 # Good for energy models with many categories
    )
    
    return p
end