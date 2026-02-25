using CSV, DataFrames, Plots

"""
    plot_node_balance(file_path, node_name, supply_ids, demand_ids, x_limits)

- node_name: String (used for the plot title)
- supply_ids: Vector of IDs (e.g., ["wind_1", "solar_pvg"])
- demand_ids: Vector of IDs (e.g., ["city_load", "h2_electrolyzer"])
"""
function plot_node_balance(file_path::String, node_name::String, 
                                    supply_ids::Vector{String}, demand_ids::Vector{String}, 
                                    x_limits::Tuple{Number, Number})
    
    df = CSV.read(file_path, DataFrame)
    
    # 1. Map IDs to actual CSV headers by appending "_edge"
    # We use broadcasting (the '.' after '*') to apply it to the whole vector
    s_cols = supply_ids .* "_edge"
    d_cols = demand_ids .* "_edge"

    # Quick check: Do these columns actually exist in the CSV?
    all_headers = names(df)
    missing_s = filter(c -> !(c in all_headers), s_cols)
    missing_d = filter(c -> !(c in all_headers), d_cols)
    
    if !isempty(missing_s) || !isempty(missing_d)
        @warn "Missing columns in CSV: $(vcat(missing_s, missing_d))"
    end

    # Keep only the columns that actually exist
    s_cols = intersect(s_cols, all_headers)
    d_cols = intersect(d_cols, all_headers)

    time_data = df.time
    
    # 2. Build the Supply Stack (Positive)
    s_matrix = !isempty(s_cols) ? Matrix(df[:, s_cols]) : zeros(length(time_data), 1)
    
    p = areaplot(time_data, s_matrix,
        labels = reshape(s_cols, 1, :),
        fillalpha = 0.7,
        title = "Nodal Balance: $node_name",
        ylabel = "Flow [MWh or MT] (+ In / - Out)",
        xlabel = "Time (Hours)",
        xlims = x_limits,
        legend = :topright,
        legend_columns = 1,
        margin = 10Plots.mm # Extra margin for the bottom legend
    )

    # 3. Build the Demand Stack (Negative)
    if !isempty(d_cols)
        # Multiply by -1 to flip the stack below the x-axis
        d_matrix = Matrix(df[:, d_cols]) .* -1
        
        areaplot!(p, time_data, d_matrix,
            labels = reshape(d_cols, 1, :),
            fillalpha = 0.7
        )
    end

    # 4. Add the zero-balance line
    hline!([0], color = :black, lw = 2, label = "")

    return p
end