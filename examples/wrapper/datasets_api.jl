module DatasetsAPI

using CatBoost
using DataFrames

train, test = load_dataset(:amazon)

end # module
