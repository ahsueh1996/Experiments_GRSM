       @Measurement(iterations = 1, batchSize = 1)
        @BenchmarkMode(Array(Mode.SingleShotTime))
        def Multinomial_LR_acc(s: Benchmarks.My_State) {
                // Run training algorithm to build the model
                // btw, what if numclasses = 2?
                s.model = new LogisticRegressionWithLBFGS()
                                .setNumClasses(10)
                                .run(s.training)
                // Compute raw scores on the test set.
                val predictionAndLabels = s.test.map { case LabeledPoint(label, features) =>
                        val prediction = s.model.predict(features)
                        (prediction, label)
                }
                val accuracy = predictionAndLabels.filter(x => x._1 == x._2).count().toDouble / predictionAndLabels.count()
                println(s"Accuracy = $accuracy")
        }
        @Benchmark
        @Fork(1)
        @Warmup(iterations = 0, batchSize = 1)
        @Measurement(iterations = 1, batchSize = 1)
        @BenchmarkMode(Array(Mode.SingleShotTime))
        def Binary_LRi_acc(s: Benchmarks.My_State) {
                // Run training algorithm to build the model
                // btw, what if numclasses = 2?
                s.model = new LogisticRegressionWithLBFGS()
                                .setNumClasses(2)
                                .run(s.training)
                // Compute raw scores on the test set.
                val predictionAndLabels = s.test.map { case LabeledPoint(label, features) =>
                        val prediction = s.model.predict(features)
                        (prediction, label)
                }
                val accuracy = predictionAndLabels.filter(x => x._1 == x._2).count().toDouble / predictionAndLabels.count()
                println(s"Accuracy = $accuracy")
        }
}
