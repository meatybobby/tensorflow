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
include "mlir/IR/OpBase.td"
include "tensorflow/compiler/mlir/tensorflow/ir/tf_op_base.td"
include "mlir/IR/PatternBase.td"

def DenseElementsAttr : ElementsAttrBase<
  CPred<"$_self.isa<DenseElementsAttr>()">,
  "non-opaque constant tensor">;

// Checks if the data format is "NHWC".
def IsDataFormatNHWC : ConstantAttr<TF_ConvnetDataFormatAttr, "\"NHWC\"">;

// Checks if the op is constant op.
def IsConstTensor :  Constraint<CPred<"dyn_cast_or_null<TF::ConstOp>($0.getDefiningOp())">>;

// Checks if the element value has a float type.
def IsFloatElementsAttr : ElementsAttrBase<
  CPred<"$_self.isa<ElementsAttr>() && "
        "getElementTypeOrSelf($_self.cast<ElementsAttr>().getType()).isa<FloatType>()">,
        "float constant tensor">;

// Checks if the boolean value is false.
def IsFalseBoolAttr : AttrConstraint<
  CPred<"!$_self.cast<BoolAttr>().getValue()">>;

// Checks if the value has only one user.
def HasOneUse : Constraint<CPred<"$0.hasOneUse()">>;

// Gets the type of a value.
def GetValueType : NativeCodeCall<"$0.getType()">;

// Checks if the value has the type of int8.
def IsInt8ElementType : Constraint<
  CPred<"getElementTypeOrSelf($0).isInteger(8)">>;

// Checks if the value has the type of int32.
def IsInt32ElementType : Constraint<
  CPred<"getElementTypeOrSelf($0).isInteger(32)">>;

// Checks if the value has the type of float32.
def IsF32ElementType : Constraint<
  CPred<"getElementTypeOrSelf($0).isF32()">>;

// Checks if the value has static shape.
def HasStaticShapeConstraint : Constraint<CPred<"HasStaticShape($0)">>;

// Checks if the value has static shape at given dims.
class HasStaticShapeAtDimsConstraint<string dims> : Constraint<
  CPred<"HasStaticShapeAtDims($0, {"# dims #"})">>;

// The rewrite rule cannot replace a value with itself, so we work around
// by cloning the root op to replicate that value. The old op will get folded.
def CloningOpResult : NativeCodeCall<
  "$_builder.clone(*op0)->getOpResult(0)">;

// Same as CloningOpResult but is used for ops with multiple results.
class CloningOpResults<int returns> : NativeCodeCall<
  "$_builder.clone(*op0)->getOpResults()", returns>;

// Creates an 1D array const with float values.
class Create1DConst<string values> : NativeCodeCall<
  "Create1DConstValue<float>($_builder, $_loc, "# values #")">;

// Creates a scalar const with float value.
class CreateScalarConst<string value> : NativeCodeCall<
  "CreateScalarConstValue<float>($_builder, $_loc, "# value #")">;

// Creates an 1D array const with integer values.
// TODO(b/239490133): Make the rule name and function name consistent.
class Create1DIntegerConst<string type, string values> : NativeCodeCall<
  "Create1DConstValue<"# type #">($_builder, $_loc, "# values #")">;

// Creates a scalar const with integer value.
class CreateScalarIntegerConst<string type, string value> : NativeCodeCall<
  "CreateScalarConstValue<"# type #">($_builder, $_loc, "# value #")">;

// Creates an I64 array attribute with given values.
class CreateI64ArrayAttr<string values> : NativeCodeCall<
  "$_builder.getI64ArrayAttr("# values #")">;

// Creates a string attribute with given values.
class CreateStringAttr<string values> : NativeCodeCall<
  "$_builder.getStringAttr("# values #")">;

// Creates a new F32 type with the same shape as the given value.
def CloneTypeWithF32ElementType : NativeCodeCall<
  "CloneTypeWithNewElementType($0.getType(), $_builder.getF32Type())">;

// Creates a new I32 type with the same shape as the given value.
def CloneTypeWithI32ElementType : NativeCodeCall<
  "CloneTypeWithNewElementType($0.getType(), $_builder.getI32Type())">;

// By default, the generated code uses  the `create` method without the output
// type field. However, for many ops, the output type field is always required.
class CreateOpWithOutputType<string op_name> : NativeCodeCall<
  "$_builder.create<"# op_name #">($_loc, $0...)">;

// Checks if the value is a float constant and its splat value is equal to `x`.
class IsSplatValueEqual<string x> : Constraint<CPred<
  "IsSplatValueEqual<float>($0, "# x #")">>;

// Checks if two values are float constants and their values are equal.
def AreSplatValuesEqual : Constraint<CPred<
  "AreSplatValuesEqual<float>($0, $1)">>;

// Checks if the value is an integer constant and its splat value is equal to x.
class IsIntSplatValueEqual<string type, string x> : Constraint<CPred<
  "IsSplatValueEqual<"# type #">($0, "# x #")">>;

// Checks if two values are integer constants and their values are equal.
class AreIntSplatValuesEqual<string type> : Constraint<CPred<
  "AreSplatValuesEqual<"# type #">($0, $1)">>;
