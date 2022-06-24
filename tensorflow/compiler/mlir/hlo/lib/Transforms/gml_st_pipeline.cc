/* Copyright 2022 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include "mlir-hlo/Transforms/gml_st_pipeline.h"

#include "mlir-hlo/Dialect/gml_st/transforms/passes.h"
#include "mlir-hlo/Dialect/mhlo/transforms/passes.h"
#include "mlir/Dialect/Linalg/Passes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"

namespace mlir {
using ::mlir::func::FuncOp;

void createGmlStPipeline(mlir::OpPassManager& pm,
                         const GmlStPipelineOptions& options) {
  // First legalize from mhlo to gml_st. These patterns have precedence over the
  // lowering to Linalg.
  pm.addNestedPass<FuncOp>(gml_st::createLegalizeMHLOToGMLPass());
  pm.addNestedPass<FuncOp>(mhlo::createLegalizeHloToLinalgPass());
  pm.addNestedPass<FuncOp>(createLinalgElementwiseOpFusionPass());
  pm.addNestedPass<FuncOp>(gml_st::createTilingPass(options.tileSizes));
}

}  // namespace mlir