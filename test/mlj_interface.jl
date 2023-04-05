
@testset "MLJ Interface" begin
    using CatBoost.MLJCatBoostInterface: CatBoostRegressor, CatBoostClassifier

    @testset "MLJ Examples" begin
        for ex in readdir(MLJ_EXAMPLES_DIR)
            @testset "$ex" begin
                # Just check the examples run, for now.
                include(joinpath(MLJ_EXAMPLES_DIR, ex))
            end
        end
    end

    @testset "CatBoostClassifier" begin
        X = (; a=[1, 4, 5, 6], b=[4, 5, 6, 7])
        y = coerce([0, 0, 1, 1], OrderedFactor)

        # MLJ Interface
        model = CatBoostClassifier(; iterations=5)
        mach = machine(model, X, y)
        MLJBase.fit!(mach)
        preds = MLJBase.predict(mach, X)
        probs = MLJBase.predict_mode(mach, X)

        serializable_fitresult = MLJBase.save(mach, mach.fitresult)
        restored_fitresult = MLJBase.restore(mach, serializable_fitresult)
    end

    @testset "CatBoostRegressor" begin
        X = (; a=[1, 4, 5, 6], b=[4, 5, 6, 7])
        y = [2.0, 4.0, 6.0, 7.0]

        # MLJ Interface
        model = CatBoostRegressor(; iterations=5)
        mach = machine(model, X, y)
        MLJBase.fit!(mach)
        preds = MLJBase.predict(mach, X)

        serializable_fitresult = MLJBase.save(mach, mach.fitresult)
        restored_fitresult = MLJBase.restore(mach, serializable_fitresult)
    end

    @testset "generic interface tests" begin
        @testset "CatBoostRegressor" begin
            data = MLJTestInterface.make_regression()
            failures, summary = MLJTestInterface.test([CatBoostRegressor], data...;
                                                      mod=@__MODULE__, verbosity=0, # bump to debug
                                                      throw=false)
            @test isempty(failures)
        end
        @testset "CatBoostClassifier" begin
            for data in [MLJTestInterface.make_binary(), MLJTestInterface.make_multiclass()]
                X = data[1]
                y = data[2]
                # catboost fails if only 1 class is present when training
                # MLJTestInterface splits the data down the middle, so the binary
                # data only has one class during training
                y[1] = y[end]
                failures, summary = MLJTestInterface.test([CatBoostClassifier], X, y;
                                                          mod=@__MODULE__, verbosity=0, # bump to debug
                                                          throw=false)
                @test isempty(failures)
            end
        end
    end
end