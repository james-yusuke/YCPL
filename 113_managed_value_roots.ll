; ModuleID = 'yc'
source_filename = "yc"

%Bytes = type { ptr, ptr, i32, i32, i1 }
%StringBuilder = type { ptr, ptr, i32, i32, i1 }
%JsonValue = type { i32, ptr, ptr, i32, i32, i1, ptr }

@.str = private unnamed_addr constant [3 x i8] c"YC\00", align 1
@.str.1 = private unnamed_addr constant [3 x i8] c"YC\00", align 1
@.str.2 = private unnamed_addr constant [5 x i8] c"YCPL\00", align 1
@.str.3 = private unnamed_addr constant [5 x i8] c"YCPL\00", align 1
@.str.4 = private unnamed_addr constant [16 x i8] c"{\22name\22:\22YCPL\22}\00", align 1
@.str.5 = private unnamed_addr constant [5 x i8] c"name\00", align 1
@.str.6 = private unnamed_addr constant [16 x i8] c"{\22name\22:\22YCPL\22}\00", align 1
@.str.7 = private unnamed_addr constant [5 x i8] c"name\00", align 1
@.fmt = private unnamed_addr constant [6 x i8] c"%lld\0A\00", align 1
@.fmt.8 = private unnamed_addr constant [6 x i8] c"%lld\0A\00", align 1
@.fmt.9 = private unnamed_addr constant [6 x i8] c"%lld\0A\00", align 1
@.fmt.10 = private unnamed_addr constant [6 x i8] c"%lld\0A\00", align 1
@.fmt.11 = private unnamed_addr constant [6 x i8] c"%lld\0A\00", align 1
@.fmt.12 = private unnamed_addr constant [6 x i8] c"%lld\0A\00", align 1
@.str.13 = private unnamed_addr constant [19 x i8] c"invalid JSON value\00", align 1
@.str.14 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@.str.15 = private unnamed_addr constant [20 x i8] c"JSON source is none\00", align 1
@.str.16 = private unnamed_addr constant [20 x i8] c"invalid JSON syntax\00", align 1
@.str.17 = private unnamed_addr constant [30 x i8] c"unexpected trailing JSON text\00", align 1
@.str.18 = private unnamed_addr constant [5 x i8] c"null\00", align 1
@.str.19 = private unnamed_addr constant [24 x i8] c"missing JSON object key\00", align 1
@.str.20 = private unnamed_addr constant [26 x i8] c"invalid JSON object value\00", align 1
@.str.21 = private unnamed_addr constant [27 x i8] c"JSON value is not an array\00", align 1
@.str.22 = private unnamed_addr constant [30 x i8] c"JSON array index out of range\00", align 1
@.str.23 = private unnamed_addr constant [24 x i8] c"invalid JSON array item\00", align 1
@.str.24 = private unnamed_addr constant [30 x i8] c"JSON array index out of range\00", align 1
@.str.25 = private unnamed_addr constant [5 x i8] c"\22id\22\00", align 1
@.str.26 = private unnamed_addr constant [9 x i8] c"\22method\22\00", align 1
@.str.27 = private unnamed_addr constant [16 x i8] c"Content-Length:\00", align 1
@.str.28 = private unnamed_addr constant [8 x i8] c"import \00", align 1
@.str.29 = private unnamed_addr constant [4 x i8] c"fn \00", align 1
@.str.30 = private unnamed_addr constant [8 x i8] c"extern \00", align 1
@.str.31 = private unnamed_addr constant [11 x i8] c"intrinsic \00", align 1
@.str.32 = private unnamed_addr constant [2 x i8] c"(\00", align 1
@.str.33 = private unnamed_addr constant [2 x i8] c")\00", align 1
@.str.34 = private unnamed_addr constant [2 x i8] c"{\00", align 1
@.str.35 = private unnamed_addr constant [9 x i8] c"println(\00", align 1
@.str.36 = private unnamed_addr constant [7 x i8] c"print(\00", align 1
@.str.37 = private unnamed_addr constant [10 x i8] c"\0Aprintln(\00", align 1
@.str.38 = private unnamed_addr constant [8 x i8] c"\0Aprint(\00", align 1
@.str.39 = private unnamed_addr constant [9 x i8] c"println(\00", align 1
@.str.40 = private unnamed_addr constant [7 x i8] c"print(\00", align 1
@.str.41 = private unnamed_addr constant [10 x i8] c"\0Aprintln(\00", align 1
@.str.42 = private unnamed_addr constant [8 x i8] c"\0Aprint(\00", align 1
@.str.43 = private unnamed_addr constant [23 x i8] c"unclosed block comment\00", align 1
@.str.44 = private unnamed_addr constant [24 x i8] c"unclosed string literal\00", align 1
@.str.45 = private unnamed_addr constant [17 x i8] c"unbalanced brace\00", align 1
@.str.46 = private unnamed_addr constant [56 x i8] c"imported std symbols must be called through their alias\00", align 1
@.str.47 = private unnamed_addr constant [29 x i8] c"malformed import declaration\00", align 1
@.str.48 = private unnamed_addr constant [31 x i8] c"malformed function declaration\00", align 1
@.str.49 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@.str.50 = private unnamed_addr constant [19 x i8] c"invalid JSON value\00", align 1
@.str.51 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@.str.52 = private unnamed_addr constant [20 x i8] c"JSON source is none\00", align 1
@.str.53 = private unnamed_addr constant [20 x i8] c"invalid JSON syntax\00", align 1
@.str.54 = private unnamed_addr constant [30 x i8] c"unexpected trailing JSON text\00", align 1
@.str.55 = private unnamed_addr constant [5 x i8] c"null\00", align 1
@.str.56 = private unnamed_addr constant [24 x i8] c"missing JSON object key\00", align 1
@.str.57 = private unnamed_addr constant [26 x i8] c"invalid JSON object value\00", align 1
@.str.58 = private unnamed_addr constant [27 x i8] c"JSON value is not an array\00", align 1
@.str.59 = private unnamed_addr constant [30 x i8] c"JSON array index out of range\00", align 1
@.str.60 = private unnamed_addr constant [24 x i8] c"invalid JSON array item\00", align 1
@.str.61 = private unnamed_addr constant [30 x i8] c"JSON array index out of range\00", align 1
@.str.62 = private unnamed_addr constant [5 x i8] c"\22id\22\00", align 1
@.str.63 = private unnamed_addr constant [9 x i8] c"\22method\22\00", align 1
@.str.64 = private unnamed_addr constant [16 x i8] c"Content-Length:\00", align 1
@.str.65 = private unnamed_addr constant [8 x i8] c"import \00", align 1
@.str.66 = private unnamed_addr constant [4 x i8] c"fn \00", align 1
@.str.67 = private unnamed_addr constant [8 x i8] c"extern \00", align 1
@.str.68 = private unnamed_addr constant [11 x i8] c"intrinsic \00", align 1
@.str.69 = private unnamed_addr constant [2 x i8] c"(\00", align 1
@.str.70 = private unnamed_addr constant [2 x i8] c")\00", align 1
@.str.71 = private unnamed_addr constant [2 x i8] c"{\00", align 1
@.str.72 = private unnamed_addr constant [9 x i8] c"println(\00", align 1
@.str.73 = private unnamed_addr constant [7 x i8] c"print(\00", align 1
@.str.74 = private unnamed_addr constant [10 x i8] c"\0Aprintln(\00", align 1
@.str.75 = private unnamed_addr constant [8 x i8] c"\0Aprint(\00", align 1
@.str.76 = private unnamed_addr constant [9 x i8] c"println(\00", align 1
@.str.77 = private unnamed_addr constant [7 x i8] c"print(\00", align 1
@.str.78 = private unnamed_addr constant [10 x i8] c"\0Aprintln(\00", align 1
@.str.79 = private unnamed_addr constant [8 x i8] c"\0Aprint(\00", align 1
@.str.80 = private unnamed_addr constant [23 x i8] c"unclosed block comment\00", align 1
@.str.81 = private unnamed_addr constant [24 x i8] c"unclosed string literal\00", align 1
@.str.82 = private unnamed_addr constant [17 x i8] c"unbalanced brace\00", align 1
@.str.83 = private unnamed_addr constant [56 x i8] c"imported std symbols must be called through their alias\00", align 1
@.str.84 = private unnamed_addr constant [29 x i8] c"malformed import declaration\00", align 1
@.str.85 = private unnamed_addr constant [31 x i8] c"malformed function declaration\00", align 1
@.str.86 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1

declare i64 @yc_runtime_live_allocations()

define internal i64 @"113_managed_value_roots__score"(i64 %before, i64 %allocated, i64 %released) {
entry:
  %out = alloca i64, align 8
  %before1 = alloca i64, align 8
  store i64 %before, ptr %before1, align 4
  %allocated2 = alloca i64, align 8
  store i64 %allocated, ptr %allocated2, align 4
  %released3 = alloca i64, align 8
  store i64 %released, ptr %released3, align 4
  call void @yc_frame_push()
  store i64 0, ptr %out, align 4
  %allocated.val = load i64, ptr %allocated2, align 4
  %before.val = load i64, ptr %before1, align 4
  %cmptmp = icmp sgt i64 %allocated.val, %before.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %compound.current = load i64, ptr %out, align 4
  %compound.add = add i64 %compound.current, 1
  store i64 %compound.add, ptr %out, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %entry
  %released.val = load i64, ptr %released3, align 4
  %before.val4 = load i64, ptr %before1, align 4
  %cmptmp5 = icmp eq i64 %released.val, %before.val4
  %1 = zext i1 %cmptmp5 to i32
  %ifcond6 = icmp ne i32 %1, 0
  br i1 %ifcond6, label %then7, label %ifcont10

then7:                                            ; preds = %ifcont
  %compound.current8 = load i64, ptr %out, align 4
  %compound.add9 = add i64 %compound.current8, 1
  store i64 %compound.add9, ptr %out, align 4
  br label %ifcont10

ifcont10:                                         ; preds = %then7, %ifcont
  %out.val = load i64, ptr %out, align 4
  call void @yc_frame_pop()
  ret i64 %out.val
}

define internal i64 @"113_managed_value_roots__check_bytes"() {
entry:
  %released = alloca i64, align 8
  %allocated = alloca i64, align 8
  %b = alloca %Bytes, align 8
  %before = alloca i64, align 8
  call void @yc_frame_push()
  %calltmp = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp, ptr %before, align 4
  %calltmp1 = call %Bytes @std__bytes__from_string(ptr @.str)
  store %Bytes %calltmp1, ptr %b, align 8
  %b.val = load %Bytes, ptr %b, align 8
  %calltmp2 = call %Bytes @std__bytes__append(%Bytes %b.val, i32 80)
  store %Bytes %calltmp2, ptr %b, align 8
  %calltmp3 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp3, ptr %allocated, align 4
  %b.val4 = load %Bytes, ptr %b, align 8
  call void @std__bytes__free(%Bytes %b.val4)
  %calltmp5 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp5, ptr %released, align 4
  %before.val = load i64, ptr %before, align 4
  %allocated.val = load i64, ptr %allocated, align 4
  %released.val = load i64, ptr %released, align 4
  %calltmp6 = call i64 @"113_managed_value_roots__score"(i64 %before.val, i64 %allocated.val, i64 %released.val)
  call void @yc_frame_pop()
  ret i64 %calltmp6
}

define internal i64 @"113_managed_value_roots__check_bytes2"() {
entry:
  %released = alloca i64, align 8
  %allocated = alloca i64, align 8
  %b = alloca %Bytes, align 8
  %before = alloca i64, align 8
  call void @yc_frame_push()
  %calltmp = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp, ptr %before, align 4
  %calltmp1 = call %Bytes @std2__bytes__from_string(ptr @.str.1)
  store %Bytes %calltmp1, ptr %b, align 8
  %b.val = load %Bytes, ptr %b, align 8
  %calltmp2 = call %Bytes @std2__bytes__append(%Bytes %b.val, i32 80)
  store %Bytes %calltmp2, ptr %b, align 8
  %calltmp3 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp3, ptr %allocated, align 4
  %b.val4 = load %Bytes, ptr %b, align 8
  call void @std2__bytes__free(%Bytes %b.val4)
  %calltmp5 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp5, ptr %released, align 4
  %before.val = load i64, ptr %before, align 4
  %allocated.val = load i64, ptr %allocated, align 4
  %released.val = load i64, ptr %released, align 4
  %calltmp6 = call i64 @"113_managed_value_roots__score"(i64 %before.val, i64 %allocated.val, i64 %released.val)
  call void @yc_frame_pop()
  ret i64 %calltmp6
}

define internal i64 @"113_managed_value_roots__check_builder"() {
entry:
  %released = alloca i64, align 8
  %allocated = alloca i64, align 8
  %b = alloca %StringBuilder, align 8
  %before = alloca i64, align 8
  call void @yc_frame_push()
  %calltmp = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp, ptr %before, align 4
  %calltmp1 = call %StringBuilder @std__text__new_builder(i32 1)
  store %StringBuilder %calltmp1, ptr %b, align 8
  %b.val = load %StringBuilder, ptr %b, align 8
  %calltmp2 = call %StringBuilder @std__text__append(%StringBuilder %b.val, ptr @.str.2)
  store %StringBuilder %calltmp2, ptr %b, align 8
  %calltmp3 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp3, ptr %allocated, align 4
  %b.val4 = load %StringBuilder, ptr %b, align 8
  call void @std__text__free_builder(%StringBuilder %b.val4)
  %calltmp5 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp5, ptr %released, align 4
  %before.val = load i64, ptr %before, align 4
  %allocated.val = load i64, ptr %allocated, align 4
  %released.val = load i64, ptr %released, align 4
  %calltmp6 = call i64 @"113_managed_value_roots__score"(i64 %before.val, i64 %allocated.val, i64 %released.val)
  call void @yc_frame_pop()
  ret i64 %calltmp6
}

define internal i64 @"113_managed_value_roots__check_builder2"() {
entry:
  %released = alloca i64, align 8
  %allocated = alloca i64, align 8
  %b = alloca %StringBuilder, align 8
  %before = alloca i64, align 8
  call void @yc_frame_push()
  %calltmp = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp, ptr %before, align 4
  %calltmp1 = call %StringBuilder @std2__text__new_builder(i32 1)
  store %StringBuilder %calltmp1, ptr %b, align 8
  %b.val = load %StringBuilder, ptr %b, align 8
  %calltmp2 = call %StringBuilder @std2__text__append(%StringBuilder %b.val, ptr @.str.3)
  store %StringBuilder %calltmp2, ptr %b, align 8
  %calltmp3 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp3, ptr %allocated, align 4
  %b.val4 = load %StringBuilder, ptr %b, align 8
  call void @std2__text__free_builder(%StringBuilder %b.val4)
  %calltmp5 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp5, ptr %released, align 4
  %before.val = load i64, ptr %before, align 4
  %allocated.val = load i64, ptr %allocated, align 4
  %released.val = load i64, ptr %released, align 4
  %calltmp6 = call i64 @"113_managed_value_roots__score"(i64 %before.val, i64 %allocated.val, i64 %released.val)
  call void @yc_frame_pop()
  ret i64 %calltmp6
}

define internal i64 @"113_managed_value_roots__check_json"() {
entry:
  %released = alloca i64, align 8
  %allocated = alloca i64, align 8
  %text_value = alloca ptr, align 8
  %name = alloca %JsonValue, align 8
  %root = alloca %JsonValue, align 8
  %before = alloca i64, align 8
  call void @yc_frame_push()
  %calltmp = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp, ptr %before, align 4
  %calltmp1 = call %JsonValue @std__json__parse(ptr @.str.4)
  store %JsonValue %calltmp1, ptr %root, align 8
  %root.val = load %JsonValue, ptr %root, align 8
  %calltmp2 = call %JsonValue @std__json__get(%JsonValue %root.val, ptr @.str.5)
  store %JsonValue %calltmp2, ptr %name, align 8
  %name.val = load %JsonValue, ptr %name, align 8
  %calltmp3 = call ptr @std__json__stringify(%JsonValue %name.val)
  store ptr %calltmp3, ptr %text_value, align 8
  %text_value.val = load ptr, ptr %text_value, align 8
  call void @std__mem__free(ptr %text_value.val)
  %calltmp4 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp4, ptr %allocated, align 4
  %root.val5 = load %JsonValue, ptr %root, align 8
  call void @std__json__free(%JsonValue %root.val5)
  %calltmp6 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp6, ptr %released, align 4
  %before.val = load i64, ptr %before, align 4
  %allocated.val = load i64, ptr %allocated, align 4
  %released.val = load i64, ptr %released, align 4
  %calltmp7 = call i64 @"113_managed_value_roots__score"(i64 %before.val, i64 %allocated.val, i64 %released.val)
  call void @yc_frame_pop()
  ret i64 %calltmp7
}

define internal i64 @"113_managed_value_roots__check_json2"() {
entry:
  %released = alloca i64, align 8
  %allocated = alloca i64, align 8
  %text_value = alloca ptr, align 8
  %name = alloca %JsonValue, align 8
  %root = alloca %JsonValue, align 8
  %before = alloca i64, align 8
  call void @yc_frame_push()
  %calltmp = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp, ptr %before, align 4
  %calltmp1 = call %JsonValue @std2__json__parse(ptr @.str.6)
  store %JsonValue %calltmp1, ptr %root, align 8
  %root.val = load %JsonValue, ptr %root, align 8
  %calltmp2 = call %JsonValue @std2__json__get(%JsonValue %root.val, ptr @.str.7)
  store %JsonValue %calltmp2, ptr %name, align 8
  %name.val = load %JsonValue, ptr %name, align 8
  %calltmp3 = call ptr @std2__json__stringify(%JsonValue %name.val)
  store ptr %calltmp3, ptr %text_value, align 8
  %text_value.val = load ptr, ptr %text_value, align 8
  call void @std__mem__free(ptr %text_value.val)
  %calltmp4 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp4, ptr %allocated, align 4
  %root.val5 = load %JsonValue, ptr %root, align 8
  call void @std2__json__free(%JsonValue %root.val5)
  %calltmp6 = call i64 @yc_runtime_live_allocations()
  store i64 %calltmp6, ptr %released, align 4
  %before.val = load i64, ptr %before, align 4
  %allocated.val = load i64, ptr %allocated, align 4
  %released.val = load i64, ptr %released, align 4
  %calltmp7 = call i64 @"113_managed_value_roots__score"(i64 %before.val, i64 %allocated.val, i64 %released.val)
  call void @yc_frame_pop()
  ret i64 %calltmp7
}

define i32 @main() {
entry:
  call void @yc_runtime_init()
  call void @yc_frame_push()
  %calltmp = call i64 @"113_managed_value_roots__check_bytes"()
  %call_printf = call i32 (ptr, ...) @printf(ptr @.fmt, i64 %calltmp)
  %calltmp1 = call i64 @"113_managed_value_roots__check_bytes2"()
  %call_printf2 = call i32 (ptr, ...) @printf(ptr @.fmt.8, i64 %calltmp1)
  %calltmp3 = call i64 @"113_managed_value_roots__check_builder"()
  %call_printf4 = call i32 (ptr, ...) @printf(ptr @.fmt.9, i64 %calltmp3)
  %calltmp5 = call i64 @"113_managed_value_roots__check_builder2"()
  %call_printf6 = call i32 (ptr, ...) @printf(ptr @.fmt.10, i64 %calltmp5)
  %calltmp7 = call i64 @"113_managed_value_roots__check_json"()
  %call_printf8 = call i32 (ptr, ...) @printf(ptr @.fmt.11, i64 %calltmp7)
  %calltmp9 = call i64 @"113_managed_value_roots__check_json2"()
  %call_printf10 = call i32 (ptr, ...) @printf(ptr @.fmt.12, i64 %calltmp9)
  call void @yc_frame_pop()
  call void @yc_runtime_shutdown()
  ret i32 0
}

declare ptr @strstr(ptr, ptr)

declare ptr @memcpy(ptr, ptr, i64)

define i32 @std2__text__len(ptr %s) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std2__str__len(ptr %s.val)
  %return.intcast = trunc i64 %calltmp to i32
  call void @yc_frame_pop()
  ret i32 %return.intcast
}

define i1 @std2__text__contains(ptr %s, ptr %needle) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %needle2 = alloca ptr, align 8
  store ptr %needle, ptr %needle2, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %needle.val = load ptr, ptr %needle2, align 8
  %calltmp = call ptr @strstr(ptr %s.val, ptr %needle.val)
  %cmptmp = icmp ne ptr %calltmp, null
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define i1 @std2__text__starts_with(ptr %s, ptr %prefix) {
entry:
  %n = alloca i64, align 8
  %i = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %prefix2 = alloca ptr, align 8
  store ptr %prefix, ptr %prefix2, align 8
  call void @yc_frame_push()
  store i32 0, ptr %i, align 4
  %prefix.val = load ptr, ptr %prefix2, align 8
  %calltmp = call i64 @std2__str__len(ptr %prefix.val)
  store i64 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %0 = sext i32 %i.val to i64
  %cmptmp = icmp slt i64 %0, %n.val
  %1 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val = load ptr, ptr %s1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %prefix.val4 = load ptr, ptr %prefix2, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.local.ptr6 = load ptr, ptr %prefix2, align 8
  %string.index.ptr.idx.i647 = sext i32 %i.val5 to i64
  %string.index.ptr8 = getelementptr inbounds i8, ptr %string.local.ptr6, i64 %string.index.ptr.idx.i647
  %string.index.load9 = load i8, ptr %string.index.ptr8, align 1
  %string.index.i3210 = zext i8 %string.index.load9 to i32
  %cmptmp11 = icmp ne i32 %string.index.i32, %string.index.i3210
  %2 = zext i1 %cmptmp11 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then:                                             ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %for.body
  br label %for.inc
}

define i32 @std2__text__find(ptr %s, ptr %needle) {
entry:
  %j = alloca i32, align 4
  %ok = alloca i1, align 1
  %i = alloca i32, align 4
  %m = alloca i64, align 8
  %n = alloca i64, align 8
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %needle2 = alloca ptr, align 8
  store ptr %needle, ptr %needle2, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std2__str__len(ptr %s.val)
  store i64 %calltmp, ptr %n, align 4
  %needle.val = load ptr, ptr %needle2, align 8
  %calltmp3 = call i64 @std2__str__len(ptr %needle.val)
  store i64 %calltmp3, ptr %m, align 4
  %m.val = load i64, ptr %m, align 4
  %cmptmp = icmp eq i64 %m.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %m.val4 = load i64, ptr %m, align 4
  %subtmp = sub i64 %n.val, %m.val4
  %1 = sext i32 %i.val to i64
  %cmptmp5 = icmp sle i64 %1, %subtmp
  %2 = zext i1 %cmptmp5 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  store i1 true, ptr %ok, align 1
  store i32 0, ptr %j, align 4
  br label %for.cond6

for.inc:                                          ; preds = %ifcont30
  %post_old31 = load i32, ptr %i, align 4
  %post_inc32 = add i32 %post_old31, 1
  store i32 %post_inc32, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

for.cond6:                                        ; preds = %for.inc8, %for.body
  %j.val = load i32, ptr %j, align 4
  %m.val10 = load i64, ptr %m, align 4
  %3 = sext i32 %j.val to i64
  %cmptmp11 = icmp slt i64 %3, %m.val10
  %4 = zext i1 %cmptmp11 to i32
  %forcond12 = icmp ne i32 %4, 0
  br i1 %forcond12, label %for.body7, label %for.after9

for.body7:                                        ; preds = %for.cond6
  %s.val13 = load ptr, ptr %s1, align 8
  %i.val14 = load i32, ptr %i, align 4
  %j.val15 = load i32, ptr %j, align 4
  %addtmp = add i32 %i.val14, %j.val15
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %needle.val16 = load ptr, ptr %needle2, align 8
  %j.val17 = load i32, ptr %j, align 4
  %string.local.ptr18 = load ptr, ptr %needle2, align 8
  %string.index.ptr.idx.i6419 = sext i32 %j.val17 to i64
  %string.index.ptr20 = getelementptr inbounds i8, ptr %string.local.ptr18, i64 %string.index.ptr.idx.i6419
  %string.index.load21 = load i8, ptr %string.index.ptr20, align 1
  %string.index.i3222 = zext i8 %string.index.load21 to i32
  %cmptmp23 = icmp ne i32 %string.index.i32, %string.index.i3222
  %5 = zext i1 %cmptmp23 to i32
  %ifcond24 = icmp ne i32 %5, 0
  br i1 %ifcond24, label %then25, label %ifcont26

for.inc8:                                         ; preds = %ifcont26
  %post_old = load i32, ptr %j, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %j, align 4
  br label %for.cond6

for.after9:                                       ; preds = %for.cond6
  %ok.val = load i1, ptr %ok, align 1
  %ifcond27 = icmp ne i1 %ok.val, false
  br i1 %ifcond27, label %then28, label %ifcont30

then25:                                           ; preds = %for.body7
  store i1 false, ptr %ok, align 1
  br label %ifcont26

ifcont26:                                         ; preds = %then25, %for.body7
  br label %for.inc8

then28:                                           ; preds = %for.after9
  %i.val29 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val29

ifcont30:                                         ; preds = %for.after9
  br label %for.inc
}

define i32 @std2__text__find_from(ptr %s, ptr %needle, i32 %start) {
entry:
  %j = alloca i32, align 4
  %ok = alloca i1, align 1
  %i = alloca i32, align 4
  %m = alloca i64, align 8
  %n = alloca i64, align 8
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %needle2 = alloca ptr, align 8
  store ptr %needle, ptr %needle2, align 8
  %start3 = alloca i32, align 4
  store i32 %start, ptr %start3, align 4
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std2__str__len(ptr %s.val)
  store i64 %calltmp, ptr %n, align 4
  %needle.val = load ptr, ptr %needle2, align 8
  %calltmp4 = call i64 @std2__str__len(ptr %needle.val)
  store i64 %calltmp4, ptr %m, align 4
  %m.val = load i64, ptr %m, align 4
  %cmptmp = icmp eq i64 %m.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %start.val = load i32, ptr %start3, align 4
  call void @yc_frame_pop()
  ret i32 %start.val

ifcont:                                           ; preds = %entry
  %start.val5 = load i32, ptr %start3, align 4
  store i32 %start.val5, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %m.val6 = load i64, ptr %m, align 4
  %subtmp = sub i64 %n.val, %m.val6
  %1 = sext i32 %i.val to i64
  %cmptmp7 = icmp sle i64 %1, %subtmp
  %2 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  store i1 true, ptr %ok, align 1
  store i32 0, ptr %j, align 4
  br label %for.cond8

for.inc:                                          ; preds = %ifcont32
  %post_old33 = load i32, ptr %i, align 4
  %post_inc34 = add i32 %post_old33, 1
  store i32 %post_inc34, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

for.cond8:                                        ; preds = %for.inc10, %for.body
  %j.val = load i32, ptr %j, align 4
  %m.val12 = load i64, ptr %m, align 4
  %3 = sext i32 %j.val to i64
  %cmptmp13 = icmp slt i64 %3, %m.val12
  %4 = zext i1 %cmptmp13 to i32
  %forcond14 = icmp ne i32 %4, 0
  br i1 %forcond14, label %for.body9, label %for.after11

for.body9:                                        ; preds = %for.cond8
  %s.val15 = load ptr, ptr %s1, align 8
  %i.val16 = load i32, ptr %i, align 4
  %j.val17 = load i32, ptr %j, align 4
  %addtmp = add i32 %i.val16, %j.val17
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %needle.val18 = load ptr, ptr %needle2, align 8
  %j.val19 = load i32, ptr %j, align 4
  %string.local.ptr20 = load ptr, ptr %needle2, align 8
  %string.index.ptr.idx.i6421 = sext i32 %j.val19 to i64
  %string.index.ptr22 = getelementptr inbounds i8, ptr %string.local.ptr20, i64 %string.index.ptr.idx.i6421
  %string.index.load23 = load i8, ptr %string.index.ptr22, align 1
  %string.index.i3224 = zext i8 %string.index.load23 to i32
  %cmptmp25 = icmp ne i32 %string.index.i32, %string.index.i3224
  %5 = zext i1 %cmptmp25 to i32
  %ifcond26 = icmp ne i32 %5, 0
  br i1 %ifcond26, label %then27, label %ifcont28

for.inc10:                                        ; preds = %ifcont28
  %post_old = load i32, ptr %j, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %j, align 4
  br label %for.cond8

for.after11:                                      ; preds = %for.cond8
  %ok.val = load i1, ptr %ok, align 1
  %ifcond29 = icmp ne i1 %ok.val, false
  br i1 %ifcond29, label %then30, label %ifcont32

then27:                                           ; preds = %for.body9
  store i1 false, ptr %ok, align 1
  br label %ifcont28

ifcont28:                                         ; preds = %then27, %for.body9
  br label %for.inc10

then30:                                           ; preds = %for.after11
  %i.val31 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val31

ifcont32:                                         ; preds = %for.after11
  br label %for.inc
}

define ptr @std2__text__slice(ptr %s, i32 %start, i32 %count) {
entry:
  %i = alloca i32, align 4
  %out = alloca ptr, align 8
  %n = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %count3 = alloca i32, align 4
  store i32 %count, ptr %count3, align 4
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %cmptmp = icmp eq ptr %s.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end5, label %lor.rhs4

lor.rhs:                                          ; preds = %lor.end5
  %count.val = load i32, ptr %count3, align 4
  %cmptmp8 = icmp slt i32 %count.val, 0
  %1 = zext i1 %cmptmp8 to i32
  %rhsbool9 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp10 = phi i1 [ true, %lor.end5 ], [ %rhsbool9, %lor.rhs ]
  %2 = zext i1 %lortmp10 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %entry
  %start.val = load i32, ptr %start2, align 4
  %cmptmp6 = icmp slt i32 %start.val, 0
  %3 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs4 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool7 = icmp ne i32 %4, 0
  br i1 %lhsbool7, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %lor.end
  %s.val11 = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std2__str__len(ptr %s.val11)
  %5 = trunc i64 %calltmp to i32
  store i32 %5, ptr %n, align 4
  %start.val12 = load i32, ptr %start2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp13 = icmp sgt i32 %start.val12, %n.val
  %6 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %6, 0
  br i1 %ifcond14, label %then15, label %ifcont17

then15:                                           ; preds = %ifcont
  %runtime.move16 = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move16

ifcont17:                                         ; preds = %ifcont
  %start.val18 = load i32, ptr %start2, align 4
  %count.val19 = load i32, ptr %count3, align 4
  %addtmp = add i32 %start.val18, %count.val19
  %n.val20 = load i32, ptr %n, align 4
  %cmptmp21 = icmp sgt i32 %addtmp, %n.val20
  %7 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %7, 0
  br i1 %ifcond22, label %then23, label %ifcont26

then23:                                           ; preds = %ifcont17
  %n.val24 = load i32, ptr %n, align 4
  %start.val25 = load i32, ptr %start2, align 4
  %subtmp = sub i32 %n.val24, %start.val25
  store i32 %subtmp, ptr %count3, align 4
  br label %ifcont26

ifcont26:                                         ; preds = %then23, %ifcont17
  %count.val27 = load i32, ptr %count3, align 4
  %addtmp28 = add i32 %count.val27, 1
  %call.arg.intcast = sext i32 %addtmp28 to i64
  %calltmp29 = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp29, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont26
  %i.val = load i32, ptr %i, align 4
  %count.val30 = load i32, ptr %count3, align 4
  %cmptmp31 = icmp slt i32 %i.val, %count.val30
  %8 = zext i1 %cmptmp31 to i32
  %forcond = icmp ne i32 %8, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %out.val = load ptr, ptr %out, align 8
  %i.val32 = load i32, ptr %i, align 4
  %string.index.addr.idx.i64 = sext i32 %i.val32 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 %string.index.addr.idx.i64
  %s.val33 = load ptr, ptr %s1, align 8
  %start.val34 = load i32, ptr %start2, align 4
  %i.val35 = load i32, ptr %i, align 4
  %addtmp36 = add i32 %start.val34, %i.val35
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp36 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %assign_trunc = trunc i32 %string.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %out.val37 = load ptr, ptr %out, align 8
  %runtime.move38 = call ptr @yc_move_to_parent(ptr %out.val37)
  call void @yc_frame_pop()
  ret ptr %runtime.move38
}

define i32 @std2__text__count_char(ptr %s, i32 %ch) {
entry:
  %n = alloca i64, align 8
  %i = alloca i32, align 4
  %total = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %ch2 = alloca i32, align 4
  store i32 %ch, ptr %ch2, align 4
  call void @yc_frame_push()
  store i32 0, ptr %total, align 4
  store i32 0, ptr %i, align 4
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std2__str__len(ptr %s.val)
  store i64 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %0 = sext i32 %i.val to i64
  %cmptmp = icmp slt i64 %0, %n.val
  %1 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val3 = load ptr, ptr %s1, align 8
  %i.val4 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val4 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %ch.val = load i32, ptr %ch2, align 4
  %cmptmp5 = icmp eq i32 %string.index.i32, %ch.val
  %2 = zext i1 %cmptmp5 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %total.val = load i32, ptr %total, align 4
  call void @yc_frame_pop()
  ret i32 %total.val

then:                                             ; preds = %for.body
  %compound.current = load i32, ptr %total, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %total, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %for.body
  br label %for.inc
}

define i32 @std2__text__line_of_offset(ptr %s, i32 %offset) {
entry:
  %i = alloca i32, align 4
  %line = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %offset2 = alloca i32, align 4
  store i32 %offset, ptr %offset2, align 4
  call void @yc_frame_push()
  store i32 0, ptr %line, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %offset.val = load i32, ptr %offset2, align 4
  %cmptmp = icmp slt i32 %i.val, %offset.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val = load ptr, ptr %s1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp4 = icmp eq i32 %string.index.i32, 10
  %1 = zext i1 %cmptmp4 to i32
  %ifcond = icmp ne i32 %1, 0
  br i1 %ifcond, label %then, label %ifcont

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %line.val = load i32, ptr %line, align 4
  call void @yc_frame_pop()
  ret i32 %line.val

then:                                             ; preds = %for.body
  %compound.current = load i32, ptr %line, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %line, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %for.body
  br label %for.inc
}

define i32 @std2__text__column_of_offset(ptr %s, i32 %offset) {
entry:
  %i = alloca i32, align 4
  %col = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %offset2 = alloca i32, align 4
  store i32 %offset, ptr %offset2, align 4
  call void @yc_frame_push()
  store i32 0, ptr %col, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %offset.val = load i32, ptr %offset2, align 4
  %cmptmp = icmp slt i32 %i.val, %offset.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val = load ptr, ptr %s1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp4 = icmp eq i32 %string.index.i32, 10
  %1 = zext i1 %cmptmp4 to i32
  %ifcond = icmp ne i32 %1, 0
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %col.val = load i32, ptr %col, align 4
  call void @yc_frame_pop()
  ret i32 %col.val

then:                                             ; preds = %for.body
  store i32 0, ptr %col, align 4
  br label %ifcont

else:                                             ; preds = %for.body
  %compound.current = load i32, ptr %col, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %col, align 4
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  br label %for.inc
}

define i32 @std2__text__utf16_col(ptr %s, i32 %offset) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %offset2 = alloca i32, align 4
  store i32 %offset, ptr %offset2, align 4
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %offset.val = load i32, ptr %offset2, align 4
  %calltmp = call i32 @std2__text__column_of_offset(ptr %s.val, i32 %offset.val)
  call void @yc_frame_pop()
  ret i32 %calltmp
}

define internal %StringBuilder @std2__text__invalid_builder() {
entry:
  %StringBuilder.tmp = alloca %StringBuilder, align 8
  call void @yc_frame_push()
  %StringBuilder.field0.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 0
  store ptr null, ptr %StringBuilder.field0.addr, align 8
  %StringBuilder.field1.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 1
  store ptr null, ptr %StringBuilder.field1.addr, align 8
  %StringBuilder.field2.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 2
  store i32 0, ptr %StringBuilder.field2.addr, align 4
  %StringBuilder.field3.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 3
  store i32 0, ptr %StringBuilder.field3.addr, align 4
  %StringBuilder.field4.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 4
  store i1 false, ptr %StringBuilder.field4.addr, align 1
  %return.load_struct = load %StringBuilder, ptr %StringBuilder.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct
}

define internal %StringBuilder @std2__text__ensure_builder_cap(%StringBuilder %b, i32 %needed) {
entry:
  %StringBuilder.tmp90 = alloca %StringBuilder, align 8
  %i = alloca i32, align 4
  %data67 = alloca ptr, align 8
  %root62 = alloca ptr, align 8
  %StringBuilder.tmp48 = alloca %StringBuilder, align 8
  %root35 = alloca ptr, align 8
  %data31 = alloca ptr, align 8
  %StringBuilder.tmp = alloca %StringBuilder, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %next = alloca i32, align 4
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  %needed2 = alloca i32, align 4
  store i32 %needed, ptr %needed2, align 4
  call void @yc_frame_push()
  %needed.val = load i32, ptr %needed2, align 4
  %cap.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 3
  %cap.val = load i32, ptr %cap.addr, align 4
  %cmptmp = icmp sle i32 %needed.val, %cap.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %b.val = load %StringBuilder, ptr %b1, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %b.val

ifcont:                                           ; preds = %entry
  %cap.addr3 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 3
  %cap.val4 = load i32, ptr %cap.addr3, align 4
  store i32 %cap.val4, ptr %next, align 4
  %next.val = load i32, ptr %next, align 4
  %cmptmp5 = icmp slt i32 %next.val, 1
  %1 = zext i1 %cmptmp5 to i32
  %ifcond6 = icmp ne i32 %1, 0
  br i1 %ifcond6, label %then7, label %ifcont8

then7:                                            ; preds = %ifcont
  store i32 1, ptr %next, align 4
  br label %ifcont8

ifcont8:                                          ; preds = %then7, %ifcont
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont8
  %next.val9 = load i32, ptr %next, align 4
  %needed.val10 = load i32, ptr %needed2, align 4
  %cmptmp11 = icmp slt i32 %next.val9, %needed.val10
  %2 = zext i1 %cmptmp11 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %next.val12 = load i32, ptr %next, align 4
  %multmp = mul i32 %next.val12, 2
  store i32 %multmp, ptr %next, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %data.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp13 = icmp eq ptr %data.val, null
  %3 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %3, 0
  br i1 %ifcond14, label %then15, label %ifcont22

then15:                                           ; preds = %for.after
  %calltmp = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp, ptr %root, align 8
  %next.val16 = load i32, ptr %next, align 4
  %addtmp = add i32 %next.val16, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp17 = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp17, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val18 = load ptr, ptr %data, align 8
  call void @std2__mem__attach_child(ptr %root.val, ptr %data.val18)
  %StringBuilder.field0.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 0
  %root.val19 = load ptr, ptr %root, align 8
  store ptr %root.val19, ptr %StringBuilder.field0.addr, align 8
  %StringBuilder.field1.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 1
  %data.val20 = load ptr, ptr %data, align 8
  store ptr %data.val20, ptr %StringBuilder.field1.addr, align 8
  %StringBuilder.field2.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 2
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  store i32 %len.val, ptr %StringBuilder.field2.addr, align 4
  %StringBuilder.field3.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 3
  %next.val21 = load i32, ptr %next, align 4
  store i32 %next.val21, ptr %StringBuilder.field3.addr, align 4
  %StringBuilder.field4.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr, align 1
  %return.load_struct = load %StringBuilder, ptr %StringBuilder.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct

ifcont22:                                         ; preds = %for.after
  %owns.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond23 = icmp ne i1 %owns.val, false
  br i1 %ifcond23, label %then24, label %ifcont60

then24:                                           ; preds = %ifcont22
  %data.addr25 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val26 = load ptr, ptr %data.addr25, align 8
  %next.val27 = load i32, ptr %next, align 4
  %addtmp28 = add i32 %next.val27, 1
  %call.arg.intcast29 = sext i32 %addtmp28 to i64
  %calltmp30 = call ptr @std2__mem__realloc(ptr %data.val26, i64 %call.arg.intcast29)
  store ptr %calltmp30, ptr %data31, align 8
  %data.val32 = load ptr, ptr %data31, align 8
  %next.val33 = load i32, ptr %next, align 4
  %string.index.addr.idx.i64 = sext i32 %next.val33 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %data.val32, i64 %string.index.addr.idx.i64
  store i8 0, ptr %string.index.addr, align 1
  %root.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 0
  %root.val34 = load ptr, ptr %root.addr, align 8
  store ptr %root.val34, ptr %root35, align 8
  %root.val36 = load ptr, ptr %root35, align 8
  %cmptmp37 = icmp eq ptr %root.val36, null
  %4 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %4, 0
  br i1 %ifcond38, label %then39, label %else

then39:                                           ; preds = %then24
  %calltmp40 = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp40, ptr %root35, align 8
  %root.val41 = load ptr, ptr %root35, align 8
  %data.val42 = load ptr, ptr %data31, align 8
  call void @std2__mem__attach_child(ptr %root.val41, ptr %data.val42)
  br label %ifcont47

else:                                             ; preds = %then24
  %root.val43 = load ptr, ptr %root35, align 8
  %data.addr44 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val45 = load ptr, ptr %data.addr44, align 8
  %data.val46 = load ptr, ptr %data31, align 8
  call void @std2__mem__replace_child(ptr %root.val43, ptr %data.val45, ptr %data.val46)
  br label %ifcont47

ifcont47:                                         ; preds = %else, %then39
  %StringBuilder.field0.addr49 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 0
  %root.val50 = load ptr, ptr %root35, align 8
  store ptr %root.val50, ptr %StringBuilder.field0.addr49, align 8
  %StringBuilder.field1.addr51 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 1
  %data.val52 = load ptr, ptr %data31, align 8
  store ptr %data.val52, ptr %StringBuilder.field1.addr51, align 8
  %StringBuilder.field2.addr53 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 2
  %len.addr54 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val55 = load i32, ptr %len.addr54, align 4
  store i32 %len.val55, ptr %StringBuilder.field2.addr53, align 4
  %StringBuilder.field3.addr56 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 3
  %next.val57 = load i32, ptr %next, align 4
  store i32 %next.val57, ptr %StringBuilder.field3.addr56, align 4
  %StringBuilder.field4.addr58 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr58, align 1
  %return.load_struct59 = load %StringBuilder, ptr %StringBuilder.tmp48, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct59

ifcont60:                                         ; preds = %ifcont22
  %calltmp61 = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp61, ptr %root62, align 8
  %next.val63 = load i32, ptr %next, align 4
  %addtmp64 = add i32 %next.val63, 1
  %call.arg.intcast65 = sext i32 %addtmp64 to i64
  %calltmp66 = call ptr @std2__mem__calloc(i64 %call.arg.intcast65, i64 1)
  store ptr %calltmp66, ptr %data67, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond68

for.cond68:                                       ; preds = %for.inc70, %ifcont60
  %i.val = load i32, ptr %i, align 4
  %len.addr72 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val73 = load i32, ptr %len.addr72, align 4
  %cmptmp74 = icmp slt i32 %i.val, %len.val73
  %5 = zext i1 %cmptmp74 to i32
  %forcond75 = icmp ne i32 %5, 0
  br i1 %forcond75, label %for.body69, label %for.after71

for.body69:                                       ; preds = %for.cond68
  %data.val76 = load ptr, ptr %data67, align 8
  %i.val77 = load i32, ptr %i, align 4
  %string.index.addr.idx.i6478 = sext i32 %i.val77 to i64
  %string.index.addr79 = getelementptr inbounds i8, ptr %data.val76, i64 %string.index.addr.idx.i6478
  %data.addr80 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val81 = load ptr, ptr %data.addr80, align 8
  %i.val82 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val82 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val81, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr79, align 1
  br label %for.inc70

for.inc70:                                        ; preds = %for.body69
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond68

for.after71:                                      ; preds = %for.cond68
  %data.val83 = load ptr, ptr %data67, align 8
  %len.addr84 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val85 = load i32, ptr %len.addr84, align 4
  %string.index.addr.idx.i6486 = sext i32 %len.val85 to i64
  %string.index.addr87 = getelementptr inbounds i8, ptr %data.val83, i64 %string.index.addr.idx.i6486
  store i8 0, ptr %string.index.addr87, align 1
  %root.val88 = load ptr, ptr %root62, align 8
  %data.val89 = load ptr, ptr %data67, align 8
  call void @std2__mem__attach_child(ptr %root.val88, ptr %data.val89)
  %StringBuilder.field0.addr91 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 0
  %root.val92 = load ptr, ptr %root62, align 8
  store ptr %root.val92, ptr %StringBuilder.field0.addr91, align 8
  %StringBuilder.field1.addr93 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 1
  %data.val94 = load ptr, ptr %data67, align 8
  store ptr %data.val94, ptr %StringBuilder.field1.addr93, align 8
  %StringBuilder.field2.addr95 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 2
  %len.addr96 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val97 = load i32, ptr %len.addr96, align 4
  store i32 %len.val97, ptr %StringBuilder.field2.addr95, align 4
  %StringBuilder.field3.addr98 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 3
  %next.val99 = load i32, ptr %next, align 4
  store i32 %next.val99, ptr %StringBuilder.field3.addr98, align 4
  %StringBuilder.field4.addr100 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr100, align 1
  %return.load_struct101 = load %StringBuilder, ptr %StringBuilder.tmp90, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct101
}

define %StringBuilder @std2__text__new_builder(i32 %cap) {
entry:
  %StringBuilder.tmp = alloca %StringBuilder, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %cap1 = alloca i32, align 4
  store i32 %cap, ptr %cap1, align 4
  call void @yc_frame_push()
  %cap.val = load i32, ptr %cap1, align 4
  %cmptmp = icmp slt i32 %cap.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp = call %StringBuilder @std2__text__invalid_builder()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %calltmp

ifcont:                                           ; preds = %entry
  %calltmp2 = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp2, ptr %root, align 8
  %cap.val3 = load i32, ptr %cap1, align 4
  %addtmp = add i32 %cap.val3, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp4 = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp4, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val = load ptr, ptr %data, align 8
  call void @std2__mem__attach_child(ptr %root.val, ptr %data.val)
  %StringBuilder.field0.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 0
  %root.val5 = load ptr, ptr %root, align 8
  store ptr %root.val5, ptr %StringBuilder.field0.addr, align 8
  %StringBuilder.field1.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 1
  %data.val6 = load ptr, ptr %data, align 8
  store ptr %data.val6, ptr %StringBuilder.field1.addr, align 8
  %StringBuilder.field2.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 2
  store i32 0, ptr %StringBuilder.field2.addr, align 4
  %StringBuilder.field3.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 3
  %cap.val7 = load i32, ptr %cap1, align 4
  store i32 %cap.val7, ptr %StringBuilder.field3.addr, align 4
  %StringBuilder.field4.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr, align 1
  %return.load_struct = load %StringBuilder, ptr %StringBuilder.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct
}

define i32 @std2__text__builder_len(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  call void @yc_frame_pop()
  ret i32 %len.val
}

define i32 @std2__text__builder_cap(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %cap.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 3
  %cap.val = load i32, ptr %cap.addr, align 4
  call void @yc_frame_pop()
  ret i32 %cap.val
}

define %StringBuilder @std2__text__append(%StringBuilder %b, ptr %src) {
entry:
  %out = alloca %StringBuilder, align 8
  %n = alloca i64, align 8
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  %src2 = alloca ptr, align 8
  store ptr %src, ptr %src2, align 8
  call void @yc_frame_push()
  %src.val = load ptr, ptr %src2, align 8
  %calltmp = call i64 @std2__str__len(ptr %src.val)
  store i64 %calltmp, ptr %n, align 4
  %b.val = load %StringBuilder, ptr %b1, align 8
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %n.val = load i64, ptr %n, align 4
  %0 = sext i32 %len.val to i64
  %addtmp = add i64 %0, %n.val
  %call.arg.intcast = trunc i64 %addtmp to i32
  %calltmp3 = call %StringBuilder @std2__text__ensure_builder_cap(%StringBuilder %b.val, i32 %call.arg.intcast)
  store %StringBuilder %calltmp3, ptr %out, align 8
  %data.addr = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %len.addr4 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val5 = load i32, ptr %len.addr4, align 4
  %ptraddtmp = getelementptr i8, ptr %data.val, i32 %len.val5
  %src.val6 = load ptr, ptr %src2, align 8
  %n.val7 = load i64, ptr %n, align 4
  %calltmp8 = call ptr @memcpy(ptr %ptraddtmp, ptr %src.val6, i64 %n.val7)
  %len.addr9 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %n.val10 = load i64, ptr %n, align 4
  %cast_int_field = trunc i64 %n.val10 to i32
  %compound.member.current = load i32, ptr %len.addr9, align 4
  %compound.add = add i32 %compound.member.current, %cast_int_field
  store i32 %compound.add, ptr %len.addr9, align 4
  %data.addr11 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val12 = load ptr, ptr %data.addr11, align 8
  %len.addr13 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val14 = load i32, ptr %len.addr13, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %len.val14 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val12, i64 %string.expr.index.addr.idx.i64
  store i8 0, ptr %string.expr.index.addr, align 1
  %out.val = load %StringBuilder, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %out.val
}

define %StringBuilder @std2__text__append_char(%StringBuilder %b, i32 %ch) {
entry:
  %out = alloca %StringBuilder, align 8
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  %ch2 = alloca i32, align 4
  store i32 %ch, ptr %ch2, align 4
  call void @yc_frame_push()
  %b.val = load %StringBuilder, ptr %b1, align 8
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %addtmp = add i32 %len.val, 1
  %calltmp = call %StringBuilder @std2__text__ensure_builder_cap(%StringBuilder %b.val, i32 %addtmp)
  store %StringBuilder %calltmp, ptr %out, align 8
  %data.addr = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %len.addr3 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %len.val4 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val, i64 %string.expr.index.addr.idx.i64
  %ch.val = load i32, ptr %ch2, align 4
  %assign_trunc = trunc i32 %ch.val to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  %len.addr5 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %compound.member.current = load i32, ptr %len.addr5, align 4
  %compound.add = add i32 %compound.member.current, 1
  store i32 %compound.add, ptr %len.addr5, align 4
  %data.addr6 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %len.addr8 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val9 = load i32, ptr %len.addr8, align 4
  %string.expr.index.addr.idx.i6410 = sext i32 %len.val9 to i64
  %string.expr.index.addr11 = getelementptr inbounds i8, ptr %data.val7, i64 %string.expr.index.addr.idx.i6410
  store i8 0, ptr %string.expr.index.addr11, align 1
  %out.val = load %StringBuilder, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %out.val
}

define ptr @std2__text__to_string(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %runtime.move = call ptr @yc_move_to_parent(ptr %data.val)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std2__text__free_builder(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %owns.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond = icmp ne i1 %owns.val, false
  br i1 %ifcond, label %then, label %ifcont12

then:                                             ; preds = %entry
  %root.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 0
  %root.val = load ptr, ptr %root.addr, align 8
  %cmptmp = icmp ne ptr %root.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond2 = icmp ne i32 %0, 0
  br i1 %ifcond2, label %then3, label %else

then3:                                            ; preds = %then
  %root.addr4 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 0
  %root.val5 = load ptr, ptr %root.addr4, align 8
  call void @std2__mem__free(ptr %root.val5)
  br label %ifcont11

else:                                             ; preds = %then
  %data.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp6 = icmp ne ptr %data.val, null
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont

then8:                                            ; preds = %else
  %data.addr9 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val10 = load ptr, ptr %data.addr9, align 8
  call void @std2__mem__free(ptr %data.val10)
  br label %ifcont

ifcont:                                           ; preds = %then8, %else
  br label %ifcont11

ifcont11:                                         ; preds = %ifcont, %then3
  br label %ifcont12

ifcont12:                                         ; preds = %ifcont11, %entry
  call void @yc_frame_pop()
  ret void
}

define ptr @std2__text__builder_new(i32 %cap) {
entry:
  %data = alloca ptr, align 8
  %cap1 = alloca i32, align 4
  store i32 %cap, ptr %cap1, align 4
  call void @yc_frame_push()
  %cap.val = load i32, ptr %cap1, align 4
  %addtmp = add i32 %cap.val, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp, ptr %data, align 8
  %data.val = load ptr, ptr %data, align 8
  %runtime.move = call ptr @yc_move_to_parent(ptr %data.val)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define i32 @std2__text__builder_append(ptr %dst, i32 %at, ptr %src) {
entry:
  %n = alloca i64, align 8
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %at2 = alloca i32, align 4
  store i32 %at, ptr %at2, align 4
  %src3 = alloca ptr, align 8
  store ptr %src, ptr %src3, align 8
  call void @yc_frame_push()
  %src.val = load ptr, ptr %src3, align 8
  %calltmp = call i64 @std2__str__len(ptr %src.val)
  store i64 %calltmp, ptr %n, align 4
  %dst.val = load ptr, ptr %dst1, align 8
  %at.val = load i32, ptr %at2, align 4
  %ptraddtmp = getelementptr i8, ptr %dst.val, i32 %at.val
  %src.val4 = load ptr, ptr %src3, align 8
  %n.val = load i64, ptr %n, align 4
  %calltmp5 = call ptr @memcpy(ptr %ptraddtmp, ptr %src.val4, i64 %n.val)
  %at.val6 = load i32, ptr %at2, align 4
  %n.val7 = load i64, ptr %n, align 4
  %0 = sext i32 %at.val6 to i64
  %addtmp = add i64 %0, %n.val7
  %return.intcast = trunc i64 %addtmp to i32
  call void @yc_frame_pop()
  ret i32 %return.intcast
}

define void @std2__text__builder_free(ptr %b) {
entry:
  %b1 = alloca ptr, align 8
  store ptr %b, ptr %b1, align 8
  call void @yc_frame_push()
  %b.val = load ptr, ptr %b1, align 8
  call void @std2__mem__free(ptr %b.val)
  call void @yc_frame_pop()
  ret void
}

define %JsonValue @std2__json__invalid_value(ptr %message) {
entry:
  %JsonValue.tmp = alloca %JsonValue, align 8
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  call void @yc_frame_push()
  %JsonValue.field0.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 0
  store i32 -1, ptr %JsonValue.field0.addr, align 4
  %JsonValue.field1.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 1
  store ptr null, ptr %JsonValue.field1.addr, align 8
  %JsonValue.field2.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 2
  store ptr null, ptr %JsonValue.field2.addr, align 8
  %JsonValue.field3.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 3
  store i32 0, ptr %JsonValue.field3.addr, align 4
  %JsonValue.field4.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 4
  store i32 0, ptr %JsonValue.field4.addr, align 4
  %JsonValue.field5.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 5
  store i1 false, ptr %JsonValue.field5.addr, align 1
  %JsonValue.field6.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 6
  %message.val = load ptr, ptr %message1, align 8
  store ptr %message.val, ptr %JsonValue.field6.addr, align 8
  %return.load_struct = load %JsonValue, ptr %JsonValue.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %return.load_struct
}

define i32 @std2__json__skip_ws(ptr %message, i32 %i) {
entry:
  %n = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %i2 = alloca i32, align 4
  store i32 %i, ptr %i2, align 4
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %calltmp = call i32 @std2__text__len(ptr %message.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i2, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i2, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val42 = load i32, ptr %i2, align 4
  call void @yc_frame_pop()
  ret i32 %i.val42

land.rhs:                                         ; preds = %for.cond
  %message.val7 = load ptr, ptr %message1, align 8
  %i.val8 = load i32, ptr %i2, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val8 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp9 = icmp eq i32 %string.index.i32, 32
  %1 = zext i1 %cmptmp9 to i32
  %lhsbool10 = icmp ne i32 %1, 0
  br i1 %lhsbool10, label %lor.end6, label %lor.rhs5

land.end:                                         ; preds = %lor.end, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool41, %lor.end ]
  %2 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

lor.rhs:                                          ; preds = %lor.end4
  %message.val31 = load ptr, ptr %message1, align 8
  %i.val32 = load i32, ptr %i2, align 4
  %string.local.ptr33 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6434 = sext i32 %i.val32 to i64
  %string.index.ptr35 = getelementptr inbounds i8, ptr %string.local.ptr33, i64 %string.index.ptr.idx.i6434
  %string.index.load36 = load i8, ptr %string.index.ptr35, align 1
  %string.index.i3237 = zext i8 %string.index.load36 to i32
  %cmptmp38 = icmp eq i32 %string.index.i3237, 9
  %3 = zext i1 %cmptmp38 to i32
  %rhsbool39 = icmp ne i32 %3, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end4
  %lortmp40 = phi i1 [ true, %lor.end4 ], [ %rhsbool39, %lor.rhs ]
  %4 = zext i1 %lortmp40 to i32
  %rhsbool41 = icmp ne i32 %4, 0
  br label %land.end

lor.rhs3:                                         ; preds = %lor.end6
  %message.val20 = load ptr, ptr %message1, align 8
  %i.val21 = load i32, ptr %i2, align 4
  %string.local.ptr22 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6423 = sext i32 %i.val21 to i64
  %string.index.ptr24 = getelementptr inbounds i8, ptr %string.local.ptr22, i64 %string.index.ptr.idx.i6423
  %string.index.load25 = load i8, ptr %string.index.ptr24, align 1
  %string.index.i3226 = zext i8 %string.index.load25 to i32
  %cmptmp27 = icmp eq i32 %string.index.i3226, 13
  %5 = zext i1 %cmptmp27 to i32
  %rhsbool28 = icmp ne i32 %5, 0
  br label %lor.end4

lor.end4:                                         ; preds = %lor.rhs3, %lor.end6
  %lortmp29 = phi i1 [ true, %lor.end6 ], [ %rhsbool28, %lor.rhs3 ]
  %6 = zext i1 %lortmp29 to i32
  %lhsbool30 = icmp ne i32 %6, 0
  br i1 %lhsbool30, label %lor.end, label %lor.rhs

lor.rhs5:                                         ; preds = %land.rhs
  %message.val11 = load ptr, ptr %message1, align 8
  %i.val12 = load i32, ptr %i2, align 4
  %string.local.ptr13 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6414 = sext i32 %i.val12 to i64
  %string.index.ptr15 = getelementptr inbounds i8, ptr %string.local.ptr13, i64 %string.index.ptr.idx.i6414
  %string.index.load16 = load i8, ptr %string.index.ptr15, align 1
  %string.index.i3217 = zext i8 %string.index.load16 to i32
  %cmptmp18 = icmp eq i32 %string.index.i3217, 10
  %7 = zext i1 %cmptmp18 to i32
  %rhsbool = icmp ne i32 %7, 0
  br label %lor.end6

lor.end6:                                         ; preds = %lor.rhs5, %land.rhs
  %lortmp = phi i1 [ true, %land.rhs ], [ %rhsbool, %lor.rhs5 ]
  %8 = zext i1 %lortmp to i32
  %lhsbool19 = icmp ne i32 %8, 0
  br i1 %lhsbool19, label %lor.end4, label %lor.rhs3
}

define internal i32 @std2__json__string_end(ptr %source, i32 %start) {
entry:
  %ch = alloca i32, align 4
  %escape = alloca i1, align 1
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %start.val = load i32, ptr %start2, align 4
  %addtmp = add i32 %start.val, 1
  store i32 %addtmp, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  store i1 false, ptr %escape, align 1
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val3 = load ptr, ptr %source1, align 8
  %i.val4 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val4 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %escape.val = load i1, ptr %escape, align 1
  %ifcond = icmp ne i1 %escape.val, false
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont15
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

then:                                             ; preds = %for.body
  store i1 false, ptr %escape, align 1
  br label %ifcont15

else:                                             ; preds = %for.body
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp5 = icmp eq i32 %ch.val, 92
  %1 = zext i1 %cmptmp5 to i32
  %ifcond6 = icmp ne i32 %1, 0
  br i1 %ifcond6, label %then7, label %else8

then7:                                            ; preds = %else
  store i1 true, ptr %escape, align 1
  br label %ifcont14

else8:                                            ; preds = %else
  %ch.val9 = load i32, ptr %ch, align 4
  %cmptmp10 = icmp eq i32 %ch.val9, 34
  %2 = zext i1 %cmptmp10 to i32
  %ifcond11 = icmp ne i32 %2, 0
  br i1 %ifcond11, label %then12, label %ifcont

then12:                                           ; preds = %else8
  %i.val13 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val13

ifcont:                                           ; preds = %else8
  br label %ifcont14

ifcont14:                                         ; preds = %ifcont, %then7
  br label %ifcont15

ifcont15:                                         ; preds = %ifcont14, %then
  br label %for.inc
}

define internal i32 @std2__json__matching_end(ptr %source, i32 %start, i32 %open_ch, i32 %close_ch) {
entry:
  %e = alloca i32, align 4
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %depth = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %open_ch3 = alloca i32, align 4
  store i32 %open_ch, ptr %open_ch3, align 4
  %close_ch4 = alloca i32, align 4
  store i32 %close_ch, ptr %close_ch4, align 4
  call void @yc_frame_push()
  store i32 0, ptr %depth, align 4
  %start.val = load i32, ptr %start2, align 4
  store i32 %start.val, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val5 = load ptr, ptr %source1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp7 = icmp eq i32 %ch.val, 34
  %1 = zext i1 %cmptmp7 to i32
  %ifcond = icmp ne i32 %1, 0
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont32
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

then:                                             ; preds = %for.body
  %source.val8 = load ptr, ptr %source1, align 8
  %i.val9 = load i32, ptr %i, align 4
  %calltmp10 = call i32 @std2__json__string_end(ptr %source.val8, i32 %i.val9)
  store i32 %calltmp10, ptr %e, align 4
  %e.val = load i32, ptr %e, align 4
  %cmptmp11 = icmp slt i32 %e.val, 0
  %2 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %2, 0
  br i1 %ifcond12, label %then13, label %ifcont

then13:                                           ; preds = %then
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %then
  %e.val14 = load i32, ptr %e, align 4
  store i32 %e.val14, ptr %i, align 4
  br label %ifcont32

else:                                             ; preds = %for.body
  %ch.val15 = load i32, ptr %ch, align 4
  %open_ch.val = load i32, ptr %open_ch3, align 4
  %cmptmp16 = icmp eq i32 %ch.val15, %open_ch.val
  %3 = zext i1 %cmptmp16 to i32
  %ifcond17 = icmp ne i32 %3, 0
  br i1 %ifcond17, label %then18, label %else19

then18:                                           ; preds = %else
  %compound.current = load i32, ptr %depth, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %depth, align 4
  br label %ifcont31

else19:                                           ; preds = %else
  %ch.val20 = load i32, ptr %ch, align 4
  %close_ch.val = load i32, ptr %close_ch4, align 4
  %cmptmp21 = icmp eq i32 %ch.val20, %close_ch.val
  %4 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %4, 0
  br i1 %ifcond22, label %then23, label %ifcont30

then23:                                           ; preds = %else19
  %compound.current24 = load i32, ptr %depth, align 4
  %compound.sub = sub i32 %compound.current24, 1
  store i32 %compound.sub, ptr %depth, align 4
  %depth.val = load i32, ptr %depth, align 4
  %cmptmp25 = icmp eq i32 %depth.val, 0
  %5 = zext i1 %cmptmp25 to i32
  %ifcond26 = icmp ne i32 %5, 0
  br i1 %ifcond26, label %then27, label %ifcont29

then27:                                           ; preds = %then23
  %i.val28 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val28

ifcont29:                                         ; preds = %then23
  br label %ifcont30

ifcont30:                                         ; preds = %ifcont29, %else19
  br label %ifcont31

ifcont31:                                         ; preds = %ifcont30, %then18
  br label %ifcont32

ifcont32:                                         ; preds = %ifcont31, %ifcont
  br label %for.inc
}

define internal i32 @std2__json__value_kind_at(ptr %source, i32 %start) {
entry:
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std2__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %i, align 4
  %source.val3 = load ptr, ptr %source1, align 8
  %calltmp4 = call i32 @std2__text__len(ptr %source.val3)
  store i32 %calltmp4, ptr %n, align 4
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp sge i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val5 = load ptr, ptr %source1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp7 = icmp eq i32 %ch.val, 123
  %1 = zext i1 %cmptmp7 to i32
  %ifcond8 = icmp ne i32 %1, 0
  br i1 %ifcond8, label %then9, label %ifcont10

then9:                                            ; preds = %ifcont
  call void @yc_frame_pop()
  ret i32 1

ifcont10:                                         ; preds = %ifcont
  %ch.val11 = load i32, ptr %ch, align 4
  %cmptmp12 = icmp eq i32 %ch.val11, 91
  %2 = zext i1 %cmptmp12 to i32
  %ifcond13 = icmp ne i32 %2, 0
  br i1 %ifcond13, label %then14, label %ifcont15

then14:                                           ; preds = %ifcont10
  call void @yc_frame_pop()
  ret i32 2

ifcont15:                                         ; preds = %ifcont10
  %ch.val16 = load i32, ptr %ch, align 4
  %cmptmp17 = icmp eq i32 %ch.val16, 34
  %3 = zext i1 %cmptmp17 to i32
  %ifcond18 = icmp ne i32 %3, 0
  br i1 %ifcond18, label %then19, label %ifcont20

then19:                                           ; preds = %ifcont15
  call void @yc_frame_pop()
  ret i32 3

ifcont20:                                         ; preds = %ifcont15
  %ch.val21 = load i32, ptr %ch, align 4
  %cmptmp22 = icmp eq i32 %ch.val21, 116
  %4 = zext i1 %cmptmp22 to i32
  %lhsbool = icmp ne i32 %4, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont20
  %ch.val23 = load i32, ptr %ch, align 4
  %cmptmp24 = icmp eq i32 %ch.val23, 102
  %5 = zext i1 %cmptmp24 to i32
  %rhsbool = icmp ne i32 %5, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont20
  %lortmp = phi i1 [ true, %ifcont20 ], [ %rhsbool, %lor.rhs ]
  %6 = zext i1 %lortmp to i32
  %ifcond25 = icmp ne i32 %6, 0
  br i1 %ifcond25, label %then26, label %ifcont27

then26:                                           ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 4

ifcont27:                                         ; preds = %lor.end
  %ch.val28 = load i32, ptr %ch, align 4
  %cmptmp29 = icmp eq i32 %ch.val28, 110
  %7 = zext i1 %cmptmp29 to i32
  %ifcond30 = icmp ne i32 %7, 0
  br i1 %ifcond30, label %then31, label %ifcont32

then31:                                           ; preds = %ifcont27
  call void @yc_frame_pop()
  ret i32 5

ifcont32:                                         ; preds = %ifcont27
  %ch.val35 = load i32, ptr %ch, align 4
  %cmptmp36 = icmp eq i32 %ch.val35, 45
  %8 = zext i1 %cmptmp36 to i32
  %lhsbool37 = icmp ne i32 %8, 0
  br i1 %lhsbool37, label %lor.end34, label %lor.rhs33

lor.rhs33:                                        ; preds = %ifcont32
  %ch.val38 = load i32, ptr %ch, align 4
  %cmptmp39 = icmp sge i32 %ch.val38, 48
  %9 = zext i1 %cmptmp39 to i32
  %lhsbool40 = icmp ne i32 %9, 0
  br i1 %lhsbool40, label %land.rhs, label %land.end

lor.end34:                                        ; preds = %land.end, %ifcont32
  %lortmp45 = phi i1 [ true, %ifcont32 ], [ %rhsbool44, %land.end ]
  %10 = zext i1 %lortmp45 to i32
  %ifcond46 = icmp ne i32 %10, 0
  br i1 %ifcond46, label %then47, label %ifcont48

land.rhs:                                         ; preds = %lor.rhs33
  %ch.val41 = load i32, ptr %ch, align 4
  %cmptmp42 = icmp sle i32 %ch.val41, 57
  %11 = zext i1 %cmptmp42 to i32
  %rhsbool43 = icmp ne i32 %11, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs33
  %landtmp = phi i1 [ false, %lor.rhs33 ], [ %rhsbool43, %land.rhs ]
  %12 = zext i1 %landtmp to i32
  %rhsbool44 = icmp ne i32 %12, 0
  br label %lor.end34

then47:                                           ; preds = %lor.end34
  call void @yc_frame_pop()
  ret i32 6

ifcont48:                                         ; preds = %lor.end34
  call void @yc_frame_pop()
  ret i32 -1
}

define internal i32 @std2__json__value_end(ptr %source, i32 %start) {
entry:
  %e42 = alloca i32, align 4
  %e26 = alloca i32, align 4
  %e = alloca i32, align 4
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std2__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %i, align 4
  %source.val3 = load ptr, ptr %source1, align 8
  %calltmp4 = call i32 @std2__text__len(ptr %source.val3)
  store i32 %calltmp4, ptr %n, align 4
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp sge i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val5 = load ptr, ptr %source1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp7 = icmp eq i32 %ch.val, 34
  %1 = zext i1 %cmptmp7 to i32
  %ifcond8 = icmp ne i32 %1, 0
  br i1 %ifcond8, label %then9, label %ifcont18

then9:                                            ; preds = %ifcont
  %source.val10 = load ptr, ptr %source1, align 8
  %i.val11 = load i32, ptr %i, align 4
  %calltmp12 = call i32 @std2__json__string_end(ptr %source.val10, i32 %i.val11)
  store i32 %calltmp12, ptr %e, align 4
  %e.val = load i32, ptr %e, align 4
  %cmptmp13 = icmp slt i32 %e.val, 0
  %2 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %2, 0
  br i1 %ifcond14, label %then15, label %ifcont16

then15:                                           ; preds = %then9
  call void @yc_frame_pop()
  ret i32 -1

ifcont16:                                         ; preds = %then9
  %e.val17 = load i32, ptr %e, align 4
  %addtmp = add i32 %e.val17, 1
  call void @yc_frame_pop()
  ret i32 %addtmp

ifcont18:                                         ; preds = %ifcont
  %ch.val19 = load i32, ptr %ch, align 4
  %cmptmp20 = icmp eq i32 %ch.val19, 123
  %3 = zext i1 %cmptmp20 to i32
  %ifcond21 = icmp ne i32 %3, 0
  br i1 %ifcond21, label %then22, label %ifcont34

then22:                                           ; preds = %ifcont18
  %source.val23 = load ptr, ptr %source1, align 8
  %i.val24 = load i32, ptr %i, align 4
  %calltmp25 = call i32 @std2__json__matching_end(ptr %source.val23, i32 %i.val24, i32 123, i32 125)
  store i32 %calltmp25, ptr %e26, align 4
  %e.val27 = load i32, ptr %e26, align 4
  %cmptmp28 = icmp slt i32 %e.val27, 0
  %4 = zext i1 %cmptmp28 to i32
  %ifcond29 = icmp ne i32 %4, 0
  br i1 %ifcond29, label %then30, label %ifcont31

then30:                                           ; preds = %then22
  call void @yc_frame_pop()
  ret i32 -1

ifcont31:                                         ; preds = %then22
  %e.val32 = load i32, ptr %e26, align 4
  %addtmp33 = add i32 %e.val32, 1
  call void @yc_frame_pop()
  ret i32 %addtmp33

ifcont34:                                         ; preds = %ifcont18
  %ch.val35 = load i32, ptr %ch, align 4
  %cmptmp36 = icmp eq i32 %ch.val35, 91
  %5 = zext i1 %cmptmp36 to i32
  %ifcond37 = icmp ne i32 %5, 0
  br i1 %ifcond37, label %then38, label %ifcont50

then38:                                           ; preds = %ifcont34
  %source.val39 = load ptr, ptr %source1, align 8
  %i.val40 = load i32, ptr %i, align 4
  %calltmp41 = call i32 @std2__json__matching_end(ptr %source.val39, i32 %i.val40, i32 91, i32 93)
  store i32 %calltmp41, ptr %e42, align 4
  %e.val43 = load i32, ptr %e42, align 4
  %cmptmp44 = icmp slt i32 %e.val43, 0
  %6 = zext i1 %cmptmp44 to i32
  %ifcond45 = icmp ne i32 %6, 0
  br i1 %ifcond45, label %then46, label %ifcont47

then46:                                           ; preds = %then38
  call void @yc_frame_pop()
  ret i32 -1

ifcont47:                                         ; preds = %then38
  %e.val48 = load i32, ptr %e42, align 4
  %addtmp49 = add i32 %e.val48, 1
  call void @yc_frame_pop()
  ret i32 %addtmp49

ifcont50:                                         ; preds = %ifcont34
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont50
  %i.val63 = load i32, ptr %i, align 4
  %n.val64 = load i32, ptr %n, align 4
  %cmptmp65 = icmp slt i32 %i.val63, %n.val64
  %7 = zext i1 %cmptmp65 to i32
  %lhsbool = icmp ne i32 %7, 0
  br i1 %lhsbool, label %land.rhs61, label %land.end62

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val140 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val140

land.rhs:                                         ; preds = %land.end52
  %source.val130 = load ptr, ptr %source1, align 8
  %i.val131 = load i32, ptr %i, align 4
  %string.local.ptr132 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64133 = sext i32 %i.val131 to i64
  %string.index.ptr134 = getelementptr inbounds i8, ptr %string.local.ptr132, i64 %string.index.ptr.idx.i64133
  %string.index.load135 = load i8, ptr %string.index.ptr134, align 1
  %string.index.i32136 = zext i8 %string.index.load135 to i32
  %cmptmp137 = icmp ne i32 %string.index.i32136, 32
  %8 = zext i1 %cmptmp137 to i32
  %rhsbool138 = icmp ne i32 %8, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.end52
  %landtmp139 = phi i1 [ false, %land.end52 ], [ %rhsbool138, %land.rhs ]
  %9 = zext i1 %landtmp139 to i32
  %forcond = icmp ne i32 %9, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs51:                                       ; preds = %land.end54
  %source.val119 = load ptr, ptr %source1, align 8
  %i.val120 = load i32, ptr %i, align 4
  %string.local.ptr121 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64122 = sext i32 %i.val120 to i64
  %string.index.ptr123 = getelementptr inbounds i8, ptr %string.local.ptr121, i64 %string.index.ptr.idx.i64122
  %string.index.load124 = load i8, ptr %string.index.ptr123, align 1
  %string.index.i32125 = zext i8 %string.index.load124 to i32
  %cmptmp126 = icmp ne i32 %string.index.i32125, 9
  %10 = zext i1 %cmptmp126 to i32
  %rhsbool127 = icmp ne i32 %10, 0
  br label %land.end52

land.end52:                                       ; preds = %land.rhs51, %land.end54
  %landtmp128 = phi i1 [ false, %land.end54 ], [ %rhsbool127, %land.rhs51 ]
  %11 = zext i1 %landtmp128 to i32
  %lhsbool129 = icmp ne i32 %11, 0
  br i1 %lhsbool129, label %land.rhs, label %land.end

land.rhs53:                                       ; preds = %land.end56
  %source.val108 = load ptr, ptr %source1, align 8
  %i.val109 = load i32, ptr %i, align 4
  %string.local.ptr110 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64111 = sext i32 %i.val109 to i64
  %string.index.ptr112 = getelementptr inbounds i8, ptr %string.local.ptr110, i64 %string.index.ptr.idx.i64111
  %string.index.load113 = load i8, ptr %string.index.ptr112, align 1
  %string.index.i32114 = zext i8 %string.index.load113 to i32
  %cmptmp115 = icmp ne i32 %string.index.i32114, 13
  %12 = zext i1 %cmptmp115 to i32
  %rhsbool116 = icmp ne i32 %12, 0
  br label %land.end54

land.end54:                                       ; preds = %land.rhs53, %land.end56
  %landtmp117 = phi i1 [ false, %land.end56 ], [ %rhsbool116, %land.rhs53 ]
  %13 = zext i1 %landtmp117 to i32
  %lhsbool118 = icmp ne i32 %13, 0
  br i1 %lhsbool118, label %land.rhs51, label %land.end52

land.rhs55:                                       ; preds = %land.end58
  %source.val97 = load ptr, ptr %source1, align 8
  %i.val98 = load i32, ptr %i, align 4
  %string.local.ptr99 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64100 = sext i32 %i.val98 to i64
  %string.index.ptr101 = getelementptr inbounds i8, ptr %string.local.ptr99, i64 %string.index.ptr.idx.i64100
  %string.index.load102 = load i8, ptr %string.index.ptr101, align 1
  %string.index.i32103 = zext i8 %string.index.load102 to i32
  %cmptmp104 = icmp ne i32 %string.index.i32103, 10
  %14 = zext i1 %cmptmp104 to i32
  %rhsbool105 = icmp ne i32 %14, 0
  br label %land.end56

land.end56:                                       ; preds = %land.rhs55, %land.end58
  %landtmp106 = phi i1 [ false, %land.end58 ], [ %rhsbool105, %land.rhs55 ]
  %15 = zext i1 %landtmp106 to i32
  %lhsbool107 = icmp ne i32 %15, 0
  br i1 %lhsbool107, label %land.rhs53, label %land.end54

land.rhs57:                                       ; preds = %land.end60
  %source.val86 = load ptr, ptr %source1, align 8
  %i.val87 = load i32, ptr %i, align 4
  %string.local.ptr88 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6489 = sext i32 %i.val87 to i64
  %string.index.ptr90 = getelementptr inbounds i8, ptr %string.local.ptr88, i64 %string.index.ptr.idx.i6489
  %string.index.load91 = load i8, ptr %string.index.ptr90, align 1
  %string.index.i3292 = zext i8 %string.index.load91 to i32
  %cmptmp93 = icmp ne i32 %string.index.i3292, 93
  %16 = zext i1 %cmptmp93 to i32
  %rhsbool94 = icmp ne i32 %16, 0
  br label %land.end58

land.end58:                                       ; preds = %land.rhs57, %land.end60
  %landtmp95 = phi i1 [ false, %land.end60 ], [ %rhsbool94, %land.rhs57 ]
  %17 = zext i1 %landtmp95 to i32
  %lhsbool96 = icmp ne i32 %17, 0
  br i1 %lhsbool96, label %land.rhs55, label %land.end56

land.rhs59:                                       ; preds = %land.end62
  %source.val75 = load ptr, ptr %source1, align 8
  %i.val76 = load i32, ptr %i, align 4
  %string.local.ptr77 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6478 = sext i32 %i.val76 to i64
  %string.index.ptr79 = getelementptr inbounds i8, ptr %string.local.ptr77, i64 %string.index.ptr.idx.i6478
  %string.index.load80 = load i8, ptr %string.index.ptr79, align 1
  %string.index.i3281 = zext i8 %string.index.load80 to i32
  %cmptmp82 = icmp ne i32 %string.index.i3281, 125
  %18 = zext i1 %cmptmp82 to i32
  %rhsbool83 = icmp ne i32 %18, 0
  br label %land.end60

land.end60:                                       ; preds = %land.rhs59, %land.end62
  %landtmp84 = phi i1 [ false, %land.end62 ], [ %rhsbool83, %land.rhs59 ]
  %19 = zext i1 %landtmp84 to i32
  %lhsbool85 = icmp ne i32 %19, 0
  br i1 %lhsbool85, label %land.rhs57, label %land.end58

land.rhs61:                                       ; preds = %for.cond
  %source.val66 = load ptr, ptr %source1, align 8
  %i.val67 = load i32, ptr %i, align 4
  %string.local.ptr68 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6469 = sext i32 %i.val67 to i64
  %string.index.ptr70 = getelementptr inbounds i8, ptr %string.local.ptr68, i64 %string.index.ptr.idx.i6469
  %string.index.load71 = load i8, ptr %string.index.ptr70, align 1
  %string.index.i3272 = zext i8 %string.index.load71 to i32
  %cmptmp73 = icmp ne i32 %string.index.i3272, 44
  %20 = zext i1 %cmptmp73 to i32
  %rhsbool = icmp ne i32 %20, 0
  br label %land.end62

land.end62:                                       ; preds = %land.rhs61, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs61 ]
  %21 = zext i1 %landtmp to i32
  %lhsbool74 = icmp ne i32 %21, 0
  br i1 %lhsbool74, label %land.rhs59, label %land.end60
}

define internal %JsonValue @std2__json__make_view(ptr %source, ptr %root, i32 %start, i32 %end_pos, i1 %should_own) {
entry:
  %JsonValue.tmp = alloca %JsonValue, align 8
  %k = alloca i32, align 4
  %real_start = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %root2 = alloca ptr, align 8
  store ptr %root, ptr %root2, align 8
  %start3 = alloca i32, align 4
  store i32 %start, ptr %start3, align 4
  %end_pos4 = alloca i32, align 4
  store i32 %end_pos, ptr %end_pos4, align 4
  %should_own5 = alloca i1, align 1
  store i1 %should_own, ptr %should_own5, align 1
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start3, align 4
  %calltmp = call i32 @std2__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %real_start, align 4
  %source.val6 = load ptr, ptr %source1, align 8
  %real_start.val = load i32, ptr %real_start, align 4
  %calltmp7 = call i32 @std2__json__value_kind_at(ptr %source.val6, i32 %real_start.val)
  store i32 %calltmp7, ptr %k, align 4
  %k.val = load i32, ptr %k, align 4
  %cmptmp = icmp slt i32 %k.val, 0
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %end_pos.val = load i32, ptr %end_pos4, align 4
  %real_start.val8 = load i32, ptr %real_start, align 4
  %cmptmp9 = icmp slt i32 %end_pos.val, %real_start.val8
  %1 = zext i1 %cmptmp9 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %calltmp10 = call %JsonValue @std2__json__invalid_value(ptr @.str.13)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp10

ifcont:                                           ; preds = %lor.end
  %JsonValue.field0.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 0
  %k.val11 = load i32, ptr %k, align 4
  store i32 %k.val11, ptr %JsonValue.field0.addr, align 4
  %JsonValue.field1.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 1
  %root.val = load ptr, ptr %root2, align 8
  store ptr %root.val, ptr %JsonValue.field1.addr, align 8
  %JsonValue.field2.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 2
  %source.val12 = load ptr, ptr %source1, align 8
  store ptr %source.val12, ptr %JsonValue.field2.addr, align 8
  %JsonValue.field3.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 3
  %real_start.val13 = load i32, ptr %real_start, align 4
  store i32 %real_start.val13, ptr %JsonValue.field3.addr, align 4
  %JsonValue.field4.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 4
  %end_pos.val14 = load i32, ptr %end_pos4, align 4
  store i32 %end_pos.val14, ptr %JsonValue.field4.addr, align 4
  %JsonValue.field5.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 5
  %should_own.val = load i1, ptr %should_own5, align 1
  store i1 %should_own.val, ptr %JsonValue.field5.addr, align 1
  %JsonValue.field6.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 6
  store ptr @.str.14, ptr %JsonValue.field6.addr, align 8
  %return.load_struct = load %JsonValue, ptr %JsonValue.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %return.load_struct
}

define %JsonValue @std2__json__parse(ptr %source) {
entry:
  %root = alloca ptr, align 8
  %trailing = alloca i32, align 4
  %end_pos = alloca i32, align 4
  %start = alloca i32, align 4
  %copy = alloca ptr, align 8
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %cmptmp = icmp eq ptr %source.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp = call %JsonValue @std2__json__invalid_value(ptr @.str.15)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %calltmp3 = call i32 @std2__text__len(ptr %source.val2)
  store i32 %calltmp3, ptr %n, align 4
  %source.val4 = load ptr, ptr %source1, align 8
  %n.val = load i32, ptr %n, align 4
  %calltmp5 = call ptr @std2__text__slice(ptr %source.val4, i32 0, i32 %n.val)
  store ptr %calltmp5, ptr %copy, align 8
  %copy.val = load ptr, ptr %copy, align 8
  %calltmp6 = call i32 @std2__json__skip_ws(ptr %copy.val, i32 0)
  store i32 %calltmp6, ptr %start, align 4
  %copy.val7 = load ptr, ptr %copy, align 8
  %start.val = load i32, ptr %start, align 4
  %calltmp8 = call i32 @std2__json__value_end(ptr %copy.val7, i32 %start.val)
  store i32 %calltmp8, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp9 = icmp slt i32 %end_pos.val, 0
  %1 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %1, 0
  br i1 %ifcond10, label %then11, label %ifcont14

then11:                                           ; preds = %ifcont
  %copy.val12 = load ptr, ptr %copy, align 8
  call void @std2__mem__free(ptr %copy.val12)
  %calltmp13 = call %JsonValue @std2__json__invalid_value(ptr @.str.16)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp13

ifcont14:                                         ; preds = %ifcont
  %copy.val15 = load ptr, ptr %copy, align 8
  %end_pos.val16 = load i32, ptr %end_pos, align 4
  %calltmp17 = call i32 @std2__json__skip_ws(ptr %copy.val15, i32 %end_pos.val16)
  store i32 %calltmp17, ptr %trailing, align 4
  %trailing.val = load i32, ptr %trailing, align 4
  %n.val18 = load i32, ptr %n, align 4
  %cmptmp19 = icmp ne i32 %trailing.val, %n.val18
  %2 = zext i1 %cmptmp19 to i32
  %ifcond20 = icmp ne i32 %2, 0
  br i1 %ifcond20, label %then21, label %ifcont24

then21:                                           ; preds = %ifcont14
  %copy.val22 = load ptr, ptr %copy, align 8
  call void @std2__mem__free(ptr %copy.val22)
  %calltmp23 = call %JsonValue @std2__json__invalid_value(ptr @.str.17)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp23

ifcont24:                                         ; preds = %ifcont14
  %calltmp25 = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp25, ptr %root, align 8
  %root.val = load ptr, ptr %root, align 8
  %copy.val26 = load ptr, ptr %copy, align 8
  call void @std2__mem__attach_child(ptr %root.val, ptr %copy.val26)
  %copy.val27 = load ptr, ptr %copy, align 8
  %root.val28 = load ptr, ptr %root, align 8
  %start.val29 = load i32, ptr %start, align 4
  %end_pos.val30 = load i32, ptr %end_pos, align 4
  %calltmp31 = call %JsonValue @std2__json__make_view(ptr %copy.val27, ptr %root.val28, i32 %start.val29, i32 %end_pos.val30, i1 true)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp31
}

define i32 @std2__json__kind(%JsonValue %value) {
entry:
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  call void @yc_frame_pop()
  ret i32 %kind.val
}

define ptr @std2__json__stringify(%JsonValue %value) {
entry:
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp slt i32 %kind.val, 0
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp2 = icmp eq ptr %source.val, null
  %1 = zext i1 %cmptmp2 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %runtime.move = call ptr @yc_move_to_parent(ptr @.str.18)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %lor.end
  %source.addr3 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val4 = load ptr, ptr %source.addr3, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %start.addr5 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val6 = load i32, ptr %start.addr5, align 4
  %subtmp = sub i32 %end.val, %start.val6
  %calltmp = call ptr @std2__text__slice(ptr %source.val4, i32 %start.val, i32 %subtmp)
  %runtime.move7 = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move7
}

define internal i1 @std2__json__key_eq(ptr %source, i32 %key_start, i32 %key_end, ptr %key) {
entry:
  %i = alloca i32, align 4
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %key_start2 = alloca i32, align 4
  store i32 %key_start, ptr %key_start2, align 4
  %key_end3 = alloca i32, align 4
  store i32 %key_end, ptr %key_end3, align 4
  %key4 = alloca ptr, align 8
  store ptr %key, ptr %key4, align 8
  call void @yc_frame_push()
  %key.val = load ptr, ptr %key4, align 8
  %calltmp = call i32 @std2__text__len(ptr %key.val)
  store i32 %calltmp, ptr %n, align 4
  %key_end.val = load i32, ptr %key_end3, align 4
  %key_start.val = load i32, ptr %key_start2, align 4
  %subtmp = sub i32 %key_end.val, %key_start.val
  %subtmp5 = sub i32 %subtmp, 1
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp ne i32 %subtmp5, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val6 = load i32, ptr %n, align 4
  %cmptmp7 = icmp slt i32 %i.val, %n.val6
  %1 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val = load ptr, ptr %source1, align 8
  %key_start.val8 = load i32, ptr %key_start2, align 4
  %addtmp = add i32 %key_start.val8, 1
  %i.val9 = load i32, ptr %i, align 4
  %addtmp10 = add i32 %addtmp, %i.val9
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp10 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %key.val11 = load ptr, ptr %key4, align 8
  %i.val12 = load i32, ptr %i, align 4
  %string.local.ptr13 = load ptr, ptr %key4, align 8
  %string.index.ptr.idx.i6414 = sext i32 %i.val12 to i64
  %string.index.ptr15 = getelementptr inbounds i8, ptr %string.local.ptr13, i64 %string.index.ptr.idx.i6414
  %string.index.load16 = load i8, ptr %string.index.ptr15, align 1
  %string.index.i3217 = zext i8 %string.index.load16 to i32
  %cmptmp18 = icmp ne i32 %string.index.i32, %string.index.i3217
  %2 = zext i1 %cmptmp18 to i32
  %ifcond19 = icmp ne i32 %2, 0
  br i1 %ifcond19, label %then20, label %ifcont21

for.inc:                                          ; preds = %ifcont21
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then20:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont21:                                         ; preds = %for.body
  br label %for.inc
}

define internal i32 @std2__json__object_value_start(%JsonValue %obj, ptr %key) {
entry:
  %value_stop = alloca i32, align 4
  %value_start = alloca i32, align 4
  %after_key = alloca i32, align 4
  %key_end = alloca i32, align 4
  %i = alloca i32, align 4
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 1
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp3 = icmp eq ptr %source.val, null
  %1 = zext i1 %cmptmp3 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %lor.end
  %source.addr4 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val5 = load ptr, ptr %source.addr4, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %addtmp = add i32 %start.val, 1
  %calltmp = call i32 @std2__json__skip_ws(ptr %source.val5, i32 %addtmp)
  store i32 %calltmp, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %cmptmp6 = icmp slt i32 %i.val, %end.val
  %3 = zext i1 %cmptmp6 to i32
  %forcond = icmp ne i32 %3, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.addr7 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val8 = load ptr, ptr %source.addr7, align 8
  %i.val9 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val9 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val8, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp10 = icmp eq i32 %string.expr.index.i32, 125
  %4 = zext i1 %cmptmp10 to i32
  %ifcond11 = icmp ne i32 %4, 0
  br i1 %ifcond11, label %then12, label %ifcont13

for.inc:                                          ; preds = %ifcont103
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

then12:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i32 -1

ifcont13:                                         ; preds = %for.body
  %source.addr14 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val15 = load ptr, ptr %source.addr14, align 8
  %i.val16 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6417 = sext i32 %i.val16 to i64
  %string.expr.index.ptr18 = getelementptr inbounds i8, ptr %source.val15, i64 %string.expr.index.ptr.idx.i6417
  %string.expr.index.load19 = load i8, ptr %string.expr.index.ptr18, align 1
  %string.expr.index.i3220 = zext i8 %string.expr.index.load19 to i32
  %cmptmp21 = icmp ne i32 %string.expr.index.i3220, 34
  %5 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %5, 0
  br i1 %ifcond22, label %then23, label %ifcont24

then23:                                           ; preds = %ifcont13
  call void @yc_frame_pop()
  ret i32 -1

ifcont24:                                         ; preds = %ifcont13
  %source.addr25 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val26 = load ptr, ptr %source.addr25, align 8
  %i.val27 = load i32, ptr %i, align 4
  %calltmp28 = call i32 @std2__json__string_end(ptr %source.val26, i32 %i.val27)
  store i32 %calltmp28, ptr %key_end, align 4
  %key_end.val = load i32, ptr %key_end, align 4
  %cmptmp29 = icmp slt i32 %key_end.val, 0
  %6 = zext i1 %cmptmp29 to i32
  %ifcond30 = icmp ne i32 %6, 0
  br i1 %ifcond30, label %then31, label %ifcont32

then31:                                           ; preds = %ifcont24
  call void @yc_frame_pop()
  ret i32 -1

ifcont32:                                         ; preds = %ifcont24
  %source.addr33 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val34 = load ptr, ptr %source.addr33, align 8
  %key_end.val35 = load i32, ptr %key_end, align 4
  %addtmp36 = add i32 %key_end.val35, 1
  %calltmp37 = call i32 @std2__json__skip_ws(ptr %source.val34, i32 %addtmp36)
  store i32 %calltmp37, ptr %after_key, align 4
  %after_key.val = load i32, ptr %after_key, align 4
  %end.addr40 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 4
  %end.val41 = load i32, ptr %end.addr40, align 4
  %cmptmp42 = icmp sge i32 %after_key.val, %end.val41
  %7 = zext i1 %cmptmp42 to i32
  %lhsbool43 = icmp ne i32 %7, 0
  br i1 %lhsbool43, label %lor.end39, label %lor.rhs38

lor.rhs38:                                        ; preds = %ifcont32
  %source.addr44 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val45 = load ptr, ptr %source.addr44, align 8
  %after_key.val46 = load i32, ptr %after_key, align 4
  %string.expr.index.ptr.idx.i6447 = sext i32 %after_key.val46 to i64
  %string.expr.index.ptr48 = getelementptr inbounds i8, ptr %source.val45, i64 %string.expr.index.ptr.idx.i6447
  %string.expr.index.load49 = load i8, ptr %string.expr.index.ptr48, align 1
  %string.expr.index.i3250 = zext i8 %string.expr.index.load49 to i32
  %cmptmp51 = icmp ne i32 %string.expr.index.i3250, 58
  %8 = zext i1 %cmptmp51 to i32
  %rhsbool52 = icmp ne i32 %8, 0
  br label %lor.end39

lor.end39:                                        ; preds = %lor.rhs38, %ifcont32
  %lortmp53 = phi i1 [ true, %ifcont32 ], [ %rhsbool52, %lor.rhs38 ]
  %9 = zext i1 %lortmp53 to i32
  %ifcond54 = icmp ne i32 %9, 0
  br i1 %ifcond54, label %then55, label %ifcont56

then55:                                           ; preds = %lor.end39
  call void @yc_frame_pop()
  ret i32 -1

ifcont56:                                         ; preds = %lor.end39
  %source.addr57 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val58 = load ptr, ptr %source.addr57, align 8
  %after_key.val59 = load i32, ptr %after_key, align 4
  %addtmp60 = add i32 %after_key.val59, 1
  %calltmp61 = call i32 @std2__json__skip_ws(ptr %source.val58, i32 %addtmp60)
  store i32 %calltmp61, ptr %value_start, align 4
  %source.addr62 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val63 = load ptr, ptr %source.addr62, align 8
  %value_start.val = load i32, ptr %value_start, align 4
  %calltmp64 = call i32 @std2__json__value_end(ptr %source.val63, i32 %value_start.val)
  store i32 %calltmp64, ptr %value_stop, align 4
  %value_stop.val = load i32, ptr %value_stop, align 4
  %cmptmp65 = icmp slt i32 %value_stop.val, 0
  %10 = zext i1 %cmptmp65 to i32
  %ifcond66 = icmp ne i32 %10, 0
  br i1 %ifcond66, label %then67, label %ifcont68

then67:                                           ; preds = %ifcont56
  call void @yc_frame_pop()
  ret i32 -1

ifcont68:                                         ; preds = %ifcont56
  %source.addr69 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val70 = load ptr, ptr %source.addr69, align 8
  %i.val71 = load i32, ptr %i, align 4
  %key_end.val72 = load i32, ptr %key_end, align 4
  %key.val = load ptr, ptr %key2, align 8
  %calltmp73 = call i1 @std2__json__key_eq(ptr %source.val70, i32 %i.val71, i32 %key_end.val72, ptr %key.val)
  %ifcond74 = icmp ne i1 %calltmp73, false
  br i1 %ifcond74, label %then75, label %ifcont77

then75:                                           ; preds = %ifcont68
  %value_start.val76 = load i32, ptr %value_start, align 4
  call void @yc_frame_pop()
  ret i32 %value_start.val76

ifcont77:                                         ; preds = %ifcont68
  %source.addr78 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val79 = load ptr, ptr %source.addr78, align 8
  %value_stop.val80 = load i32, ptr %value_stop, align 4
  %calltmp81 = call i32 @std2__json__skip_ws(ptr %source.val79, i32 %value_stop.val80)
  store i32 %calltmp81, ptr %i, align 4
  %i.val82 = load i32, ptr %i, align 4
  %end.addr83 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 4
  %end.val84 = load i32, ptr %end.addr83, align 4
  %cmptmp85 = icmp slt i32 %i.val82, %end.val84
  %11 = zext i1 %cmptmp85 to i32
  %lhsbool86 = icmp ne i32 %11, 0
  br i1 %lhsbool86, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont77
  %source.addr87 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val88 = load ptr, ptr %source.addr87, align 8
  %i.val89 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6490 = sext i32 %i.val89 to i64
  %string.expr.index.ptr91 = getelementptr inbounds i8, ptr %source.val88, i64 %string.expr.index.ptr.idx.i6490
  %string.expr.index.load92 = load i8, ptr %string.expr.index.ptr91, align 1
  %string.expr.index.i3293 = zext i8 %string.expr.index.load92 to i32
  %cmptmp94 = icmp eq i32 %string.expr.index.i3293, 44
  %12 = zext i1 %cmptmp94 to i32
  %rhsbool95 = icmp ne i32 %12, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont77
  %landtmp = phi i1 [ false, %ifcont77 ], [ %rhsbool95, %land.rhs ]
  %13 = zext i1 %landtmp to i32
  %ifcond96 = icmp ne i32 %13, 0
  br i1 %ifcond96, label %then97, label %ifcont103

then97:                                           ; preds = %land.end
  %source.addr98 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val99 = load ptr, ptr %source.addr98, align 8
  %i.val100 = load i32, ptr %i, align 4
  %addtmp101 = add i32 %i.val100, 1
  %calltmp102 = call i32 @std2__json__skip_ws(ptr %source.val99, i32 %addtmp101)
  store i32 %calltmp102, ptr %i, align 4
  br label %ifcont103

ifcont103:                                        ; preds = %then97, %land.end
  br label %for.inc
}

define %JsonValue @std2__json__get(%JsonValue %obj, ptr %key) {
entry:
  %end_pos = alloca i32, align 4
  %start = alloca i32, align 4
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std2__json__object_value_start(%JsonValue %obj.val, ptr %key.val)
  store i32 %calltmp, ptr %start, align 4
  %start.val = load i32, ptr %start, align 4
  %cmptmp = icmp slt i32 %start.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp3 = call %JsonValue @std2__json__invalid_value(ptr @.str.19)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp3

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.val4 = load i32, ptr %start, align 4
  %calltmp5 = call i32 @std2__json__value_end(ptr %source.val, i32 %start.val4)
  store i32 %calltmp5, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp6 = icmp slt i32 %end_pos.val, 0
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont10

then8:                                            ; preds = %ifcont
  %calltmp9 = call %JsonValue @std2__json__invalid_value(ptr @.str.20)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp9

ifcont10:                                         ; preds = %ifcont
  %source.addr11 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val12 = load ptr, ptr %source.addr11, align 8
  %root.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 1
  %root.val = load ptr, ptr %root.addr, align 8
  %start.val13 = load i32, ptr %start, align 4
  %end_pos.val14 = load i32, ptr %end_pos, align 4
  %calltmp15 = call %JsonValue @std2__json__make_view(ptr %source.val12, ptr %root.val, i32 %start.val13, i32 %end_pos.val14, i1 false)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp15
}

define internal ptr @std2__json__decode_string_slice(ptr %source, i32 %start, i32 %end_pos) {
entry:
  %esc = alloca i32, align 4
  %ch = alloca i32, align 4
  %j = alloca i32, align 4
  %i = alloca i32, align 4
  %out = alloca ptr, align 8
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %end_pos3 = alloca i32, align 4
  store i32 %end_pos, ptr %end_pos3, align 4
  call void @yc_frame_push()
  %start.val = load i32, ptr %start2, align 4
  %cmptmp = icmp slt i32 %start.val, 0
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end5, label %lor.rhs4

lor.rhs:                                          ; preds = %lor.end5
  %source.val = load ptr, ptr %source1, align 8
  %start.val9 = load i32, ptr %start2, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %start.val9 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp10 = icmp ne i32 %string.index.i32, 34
  %1 = zext i1 %cmptmp10 to i32
  %rhsbool11 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp12 = phi i1 [ true, %lor.end5 ], [ %rhsbool11, %lor.rhs ]
  %2 = zext i1 %lortmp12 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %entry
  %end_pos.val = load i32, ptr %end_pos3, align 4
  %start.val6 = load i32, ptr %start2, align 4
  %cmptmp7 = icmp sle i32 %end_pos.val, %start.val6
  %3 = zext i1 %cmptmp7 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs4 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool8 = icmp ne i32 %4, 0
  br i1 %lhsbool8, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %lor.end
  %end_pos.val13 = load i32, ptr %end_pos3, align 4
  %start.val14 = load i32, ptr %start2, align 4
  %subtmp = sub i32 %end_pos.val13, %start.val14
  %addtmp = add i32 %subtmp, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp, ptr %out, align 8
  %start.val15 = load i32, ptr %start2, align 4
  %addtmp16 = add i32 %start.val15, 1
  store i32 %addtmp16, ptr %i, align 4
  store i32 0, ptr %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %end_pos.val17 = load i32, ptr %end_pos3, align 4
  %subtmp18 = sub i32 %end_pos.val17, 1
  %cmptmp19 = icmp slt i32 %i.val, %subtmp18
  %5 = zext i1 %cmptmp19 to i32
  %forcond = icmp ne i32 %5, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val20 = load ptr, ptr %source1, align 8
  %i.val21 = load i32, ptr %i, align 4
  %string.local.ptr22 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6423 = sext i32 %i.val21 to i64
  %string.index.ptr24 = getelementptr inbounds i8, ptr %string.local.ptr22, i64 %string.index.ptr.idx.i6423
  %string.index.load25 = load i8, ptr %string.index.ptr24, align 1
  %string.index.i3226 = zext i8 %string.index.load25 to i32
  store i32 %string.index.i3226, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp27 = icmp eq i32 %ch.val, 92
  %6 = zext i1 %cmptmp27 to i32
  %ifcond28 = icmp ne i32 %6, 0
  br i1 %ifcond28, label %then29, label %else98

for.inc:                                          ; preds = %ifcont105
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %out.val108 = load ptr, ptr %out, align 8
  %runtime.move109 = call ptr @yc_move_to_parent(ptr %out.val108)
  call void @yc_frame_pop()
  ret ptr %runtime.move109

then29:                                           ; preds = %for.body
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  %source.val30 = load ptr, ptr %source1, align 8
  %i.val31 = load i32, ptr %i, align 4
  %string.local.ptr32 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6433 = sext i32 %i.val31 to i64
  %string.index.ptr34 = getelementptr inbounds i8, ptr %string.local.ptr32, i64 %string.index.ptr.idx.i6433
  %string.index.load35 = load i8, ptr %string.index.ptr34, align 1
  %string.index.i3236 = zext i8 %string.index.load35 to i32
  store i32 %string.index.i3236, ptr %esc, align 4
  %esc.val = load i32, ptr %esc, align 4
  %cmptmp37 = icmp eq i32 %esc.val, 110
  %7 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %7, 0
  br i1 %ifcond38, label %then39, label %else

then39:                                           ; preds = %then29
  %out.val = load ptr, ptr %out, align 8
  %j.val = load i32, ptr %j, align 4
  %string.index.addr.idx.i64 = sext i32 %j.val to i64
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 %string.index.addr.idx.i64
  store i8 10, ptr %string.index.addr, align 1
  br label %ifcont97

else:                                             ; preds = %then29
  %esc.val40 = load i32, ptr %esc, align 4
  %cmptmp41 = icmp eq i32 %esc.val40, 114
  %8 = zext i1 %cmptmp41 to i32
  %ifcond42 = icmp ne i32 %8, 0
  br i1 %ifcond42, label %then43, label %else48

then43:                                           ; preds = %else
  %out.val44 = load ptr, ptr %out, align 8
  %j.val45 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6446 = sext i32 %j.val45 to i64
  %string.index.addr47 = getelementptr inbounds i8, ptr %out.val44, i64 %string.index.addr.idx.i6446
  store i8 13, ptr %string.index.addr47, align 1
  br label %ifcont96

else48:                                           ; preds = %else
  %esc.val49 = load i32, ptr %esc, align 4
  %cmptmp50 = icmp eq i32 %esc.val49, 116
  %9 = zext i1 %cmptmp50 to i32
  %ifcond51 = icmp ne i32 %9, 0
  br i1 %ifcond51, label %then52, label %else57

then52:                                           ; preds = %else48
  %out.val53 = load ptr, ptr %out, align 8
  %j.val54 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6455 = sext i32 %j.val54 to i64
  %string.index.addr56 = getelementptr inbounds i8, ptr %out.val53, i64 %string.index.addr.idx.i6455
  store i8 9, ptr %string.index.addr56, align 1
  br label %ifcont95

else57:                                           ; preds = %else48
  %esc.val58 = load i32, ptr %esc, align 4
  %cmptmp59 = icmp eq i32 %esc.val58, 34
  %10 = zext i1 %cmptmp59 to i32
  %ifcond60 = icmp ne i32 %10, 0
  br i1 %ifcond60, label %then61, label %else66

then61:                                           ; preds = %else57
  %out.val62 = load ptr, ptr %out, align 8
  %j.val63 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6464 = sext i32 %j.val63 to i64
  %string.index.addr65 = getelementptr inbounds i8, ptr %out.val62, i64 %string.index.addr.idx.i6464
  store i8 34, ptr %string.index.addr65, align 1
  br label %ifcont94

else66:                                           ; preds = %else57
  %esc.val67 = load i32, ptr %esc, align 4
  %cmptmp68 = icmp eq i32 %esc.val67, 92
  %11 = zext i1 %cmptmp68 to i32
  %ifcond69 = icmp ne i32 %11, 0
  br i1 %ifcond69, label %then70, label %else75

then70:                                           ; preds = %else66
  %out.val71 = load ptr, ptr %out, align 8
  %j.val72 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6473 = sext i32 %j.val72 to i64
  %string.index.addr74 = getelementptr inbounds i8, ptr %out.val71, i64 %string.index.addr.idx.i6473
  store i8 92, ptr %string.index.addr74, align 1
  br label %ifcont93

else75:                                           ; preds = %else66
  %esc.val76 = load i32, ptr %esc, align 4
  %cmptmp77 = icmp eq i32 %esc.val76, 117
  %12 = zext i1 %cmptmp77 to i32
  %ifcond78 = icmp ne i32 %12, 0
  br i1 %ifcond78, label %then79, label %else86

then79:                                           ; preds = %else75
  %out.val80 = load ptr, ptr %out, align 8
  %j.val81 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6482 = sext i32 %j.val81 to i64
  %string.index.addr83 = getelementptr inbounds i8, ptr %out.val80, i64 %string.index.addr.idx.i6482
  store i8 63, ptr %string.index.addr83, align 1
  %compound.current84 = load i32, ptr %i, align 4
  %compound.add85 = add i32 %compound.current84, 4
  store i32 %compound.add85, ptr %i, align 4
  br label %ifcont92

else86:                                           ; preds = %else75
  %out.val87 = load ptr, ptr %out, align 8
  %j.val88 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6489 = sext i32 %j.val88 to i64
  %string.index.addr90 = getelementptr inbounds i8, ptr %out.val87, i64 %string.index.addr.idx.i6489
  %esc.val91 = load i32, ptr %esc, align 4
  %assign_trunc = trunc i32 %esc.val91 to i8
  store i8 %assign_trunc, ptr %string.index.addr90, align 1
  br label %ifcont92

ifcont92:                                         ; preds = %else86, %then79
  br label %ifcont93

ifcont93:                                         ; preds = %ifcont92, %then70
  br label %ifcont94

ifcont94:                                         ; preds = %ifcont93, %then61
  br label %ifcont95

ifcont95:                                         ; preds = %ifcont94, %then52
  br label %ifcont96

ifcont96:                                         ; preds = %ifcont95, %then43
  br label %ifcont97

ifcont97:                                         ; preds = %ifcont96, %then39
  br label %ifcont105

else98:                                           ; preds = %for.body
  %out.val99 = load ptr, ptr %out, align 8
  %j.val100 = load i32, ptr %j, align 4
  %string.index.addr.idx.i64101 = sext i32 %j.val100 to i64
  %string.index.addr102 = getelementptr inbounds i8, ptr %out.val99, i64 %string.index.addr.idx.i64101
  %ch.val103 = load i32, ptr %ch, align 4
  %assign_trunc104 = trunc i32 %ch.val103 to i8
  store i8 %assign_trunc104, ptr %string.index.addr102, align 1
  br label %ifcont105

ifcont105:                                        ; preds = %else98, %ifcont97
  %compound.current106 = load i32, ptr %j, align 4
  %compound.add107 = add i32 %compound.current106, 1
  store i32 %compound.add107, ptr %j, align 4
  br label %for.inc
}

define ptr @std2__json__get_string(%JsonValue %obj, ptr %key) {
entry:
  %value = alloca %JsonValue, align 8
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call %JsonValue @std2__json__get(%JsonValue %obj.val, ptr %key.val)
  store %JsonValue %calltmp, ptr %value, align 8
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 3
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %calltmp3 = call ptr @std2__json__decode_string_slice(ptr %source.val, i32 %start.val, i32 %end.val)
  %runtime.move4 = call ptr @yc_move_to_parent(ptr %calltmp3)
  call void @yc_frame_pop()
  ret ptr %runtime.move4
}

define internal i32 @std2__json__parse_i32_slice(ptr %source, i32 %start, i32 %end_pos) {
entry:
  %value = alloca i32, align 4
  %sign = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %end_pos3 = alloca i32, align 4
  store i32 %end_pos, ptr %end_pos3, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std2__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %i, align 4
  store i32 1, ptr %sign, align 4
  %i.val = load i32, ptr %i, align 4
  %end_pos.val = load i32, ptr %end_pos3, align 4
  %cmptmp = icmp slt i32 %i.val, %end_pos.val
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %source.val4 = load ptr, ptr %source1, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val5 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp6 = icmp eq i32 %string.index.i32, 45
  %1 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %landtmp = phi i1 [ false, %entry ], [ %rhsbool, %land.rhs ]
  %2 = zext i1 %landtmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %land.end
  store i32 -1, ptr %sign, align 4
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %land.end
  store i32 0, ptr %value, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val11 = load i32, ptr %i, align 4
  %end_pos.val12 = load i32, ptr %end_pos3, align 4
  %cmptmp13 = icmp slt i32 %i.val11, %end_pos.val12
  %3 = zext i1 %cmptmp13 to i32
  %lhsbool14 = icmp ne i32 %3, 0
  br i1 %lhsbool14, label %land.rhs9, label %land.end10

for.body:                                         ; preds = %land.end8
  %value.val = load i32, ptr %value, align 4
  %multmp = mul i32 %value.val, 10
  %source.val36 = load ptr, ptr %source1, align 8
  %i.val37 = load i32, ptr %i, align 4
  %string.local.ptr38 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6439 = sext i32 %i.val37 to i64
  %string.index.ptr40 = getelementptr inbounds i8, ptr %string.local.ptr38, i64 %string.index.ptr.idx.i6439
  %string.index.load41 = load i8, ptr %string.index.ptr40, align 1
  %string.index.i3242 = zext i8 %string.index.load41 to i32
  %subtmp = sub i32 %string.index.i3242, 48
  %addtmp = add i32 %multmp, %subtmp
  store i32 %addtmp, ptr %value, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end8
  %value.val43 = load i32, ptr %value, align 4
  %sign.val = load i32, ptr %sign, align 4
  %multmp44 = mul i32 %value.val43, %sign.val
  call void @yc_frame_pop()
  ret i32 %multmp44

land.rhs7:                                        ; preds = %land.end10
  %source.val26 = load ptr, ptr %source1, align 8
  %i.val27 = load i32, ptr %i, align 4
  %string.local.ptr28 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6429 = sext i32 %i.val27 to i64
  %string.index.ptr30 = getelementptr inbounds i8, ptr %string.local.ptr28, i64 %string.index.ptr.idx.i6429
  %string.index.load31 = load i8, ptr %string.index.ptr30, align 1
  %string.index.i3232 = zext i8 %string.index.load31 to i32
  %cmptmp33 = icmp sle i32 %string.index.i3232, 57
  %4 = zext i1 %cmptmp33 to i32
  %rhsbool34 = icmp ne i32 %4, 0
  br label %land.end8

land.end8:                                        ; preds = %land.rhs7, %land.end10
  %landtmp35 = phi i1 [ false, %land.end10 ], [ %rhsbool34, %land.rhs7 ]
  %5 = zext i1 %landtmp35 to i32
  %forcond = icmp ne i32 %5, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs9:                                        ; preds = %for.cond
  %source.val15 = load ptr, ptr %source1, align 8
  %i.val16 = load i32, ptr %i, align 4
  %string.local.ptr17 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6418 = sext i32 %i.val16 to i64
  %string.index.ptr19 = getelementptr inbounds i8, ptr %string.local.ptr17, i64 %string.index.ptr.idx.i6418
  %string.index.load20 = load i8, ptr %string.index.ptr19, align 1
  %string.index.i3221 = zext i8 %string.index.load20 to i32
  %cmptmp22 = icmp sge i32 %string.index.i3221, 48
  %6 = zext i1 %cmptmp22 to i32
  %rhsbool23 = icmp ne i32 %6, 0
  br label %land.end10

land.end10:                                       ; preds = %land.rhs9, %for.cond
  %landtmp24 = phi i1 [ false, %for.cond ], [ %rhsbool23, %land.rhs9 ]
  %7 = zext i1 %landtmp24 to i32
  %lhsbool25 = icmp ne i32 %7, 0
  br i1 %lhsbool25, label %land.rhs7, label %land.end8
}

define i32 @std2__json__get_i32(%JsonValue %obj, ptr %key) {
entry:
  %value = alloca %JsonValue, align 8
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call %JsonValue @std2__json__get(%JsonValue %obj.val, ptr %key.val)
  store %JsonValue %calltmp, ptr %value, align 8
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 6
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %calltmp3 = call i32 @std2__json__parse_i32_slice(ptr %source.val, i32 %start.val, i32 %end.val)
  call void @yc_frame_pop()
  ret i32 %calltmp3
}

define i1 @std2__json__get_bool(%JsonValue %obj, ptr %key) {
entry:
  %value = alloca %JsonValue, align 8
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call %JsonValue @std2__json__get(%JsonValue %obj.val, ptr %key.val)
  store %JsonValue %calltmp, ptr %value, align 8
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 4
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %start.val to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp3 = icmp eq i32 %string.expr.index.i32, 116
  %1 = zext i1 %cmptmp3 to i32
  %return.intcast = trunc i32 %1 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define %JsonValue @std2__json__at(%JsonValue %array, i32 %index) {
entry:
  %end_pos = alloca i32, align 4
  %current = alloca i32, align 4
  %i = alloca i32, align 4
  %array1 = alloca %JsonValue, align 8
  store %JsonValue %array, ptr %array1, align 8
  %index2 = alloca i32, align 4
  store i32 %index, ptr %index2, align 4
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 2
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp3 = icmp eq ptr %source.val, null
  %1 = zext i1 %cmptmp3 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %calltmp = call %JsonValue @std2__json__invalid_value(ptr @.str.21)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp

ifcont:                                           ; preds = %lor.end
  %source.addr4 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val5 = load ptr, ptr %source.addr4, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %addtmp = add i32 %start.val, 1
  %calltmp6 = call i32 @std2__json__skip_ws(ptr %source.val5, i32 %addtmp)
  store i32 %calltmp6, ptr %i, align 4
  store i32 0, ptr %current, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %cmptmp7 = icmp slt i32 %i.val, %end.val
  %3 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %3, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.addr8 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val9 = load ptr, ptr %source.addr8, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val10 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val9, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp11 = icmp eq i32 %string.expr.index.i32, 93
  %4 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %4, 0
  br i1 %ifcond12, label %then13, label %ifcont15

for.inc:                                          ; preds = %ifcont59
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %calltmp60 = call %JsonValue @std2__json__invalid_value(ptr @.str.24)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp60

then13:                                           ; preds = %for.body
  %calltmp14 = call %JsonValue @std2__json__invalid_value(ptr @.str.22)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp14

ifcont15:                                         ; preds = %for.body
  %source.addr16 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val17 = load ptr, ptr %source.addr16, align 8
  %i.val18 = load i32, ptr %i, align 4
  %calltmp19 = call i32 @std2__json__value_end(ptr %source.val17, i32 %i.val18)
  store i32 %calltmp19, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp20 = icmp slt i32 %end_pos.val, 0
  %5 = zext i1 %cmptmp20 to i32
  %ifcond21 = icmp ne i32 %5, 0
  br i1 %ifcond21, label %then22, label %ifcont24

then22:                                           ; preds = %ifcont15
  %calltmp23 = call %JsonValue @std2__json__invalid_value(ptr @.str.23)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp23

ifcont24:                                         ; preds = %ifcont15
  %current.val = load i32, ptr %current, align 4
  %index.val = load i32, ptr %index2, align 4
  %cmptmp25 = icmp eq i32 %current.val, %index.val
  %6 = zext i1 %cmptmp25 to i32
  %ifcond26 = icmp ne i32 %6, 0
  br i1 %ifcond26, label %then27, label %ifcont33

then27:                                           ; preds = %ifcont24
  %source.addr28 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val29 = load ptr, ptr %source.addr28, align 8
  %root.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 1
  %root.val = load ptr, ptr %root.addr, align 8
  %i.val30 = load i32, ptr %i, align 4
  %end_pos.val31 = load i32, ptr %end_pos, align 4
  %calltmp32 = call %JsonValue @std2__json__make_view(ptr %source.val29, ptr %root.val, i32 %i.val30, i32 %end_pos.val31, i1 false)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp32

ifcont33:                                         ; preds = %ifcont24
  %compound.current = load i32, ptr %current, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %current, align 4
  %source.addr34 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val35 = load ptr, ptr %source.addr34, align 8
  %end_pos.val36 = load i32, ptr %end_pos, align 4
  %calltmp37 = call i32 @std2__json__skip_ws(ptr %source.val35, i32 %end_pos.val36)
  store i32 %calltmp37, ptr %i, align 4
  %i.val38 = load i32, ptr %i, align 4
  %end.addr39 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 4
  %end.val40 = load i32, ptr %end.addr39, align 4
  %cmptmp41 = icmp slt i32 %i.val38, %end.val40
  %7 = zext i1 %cmptmp41 to i32
  %lhsbool42 = icmp ne i32 %7, 0
  br i1 %lhsbool42, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont33
  %source.addr43 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val44 = load ptr, ptr %source.addr43, align 8
  %i.val45 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6446 = sext i32 %i.val45 to i64
  %string.expr.index.ptr47 = getelementptr inbounds i8, ptr %source.val44, i64 %string.expr.index.ptr.idx.i6446
  %string.expr.index.load48 = load i8, ptr %string.expr.index.ptr47, align 1
  %string.expr.index.i3249 = zext i8 %string.expr.index.load48 to i32
  %cmptmp50 = icmp eq i32 %string.expr.index.i3249, 44
  %8 = zext i1 %cmptmp50 to i32
  %rhsbool51 = icmp ne i32 %8, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont33
  %landtmp = phi i1 [ false, %ifcont33 ], [ %rhsbool51, %land.rhs ]
  %9 = zext i1 %landtmp to i32
  %ifcond52 = icmp ne i32 %9, 0
  br i1 %ifcond52, label %then53, label %ifcont59

then53:                                           ; preds = %land.end
  %source.addr54 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val55 = load ptr, ptr %source.addr54, align 8
  %i.val56 = load i32, ptr %i, align 4
  %addtmp57 = add i32 %i.val56, 1
  %calltmp58 = call i32 @std2__json__skip_ws(ptr %source.val55, i32 %addtmp57)
  store i32 %calltmp58, ptr %i, align 4
  br label %ifcont59

ifcont59:                                         ; preds = %then53, %land.end
  br label %for.inc
}

define i32 @std2__json__len(%JsonValue %value) {
entry:
  %value_stop = alloca i32, align 4
  %value_start = alloca i32, align 4
  %after_key = alloca i32, align 4
  %key_end = alloca i32, align 4
  %i62 = alloca i32, align 4
  %count55 = alloca i32, align 4
  %end_pos = alloca i32, align 4
  %i = alloca i32, align 4
  %count = alloca i32, align 4
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %source.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp = icmp eq ptr %source.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp2 = icmp eq i32 %kind.val, 2
  %1 = zext i1 %cmptmp2 to i32
  %ifcond3 = icmp ne i32 %1, 0
  br i1 %ifcond3, label %then4, label %ifcont49

then4:                                            ; preds = %ifcont
  store i32 0, ptr %count, align 4
  %source.addr5 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val6 = load ptr, ptr %source.addr5, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %addtmp = add i32 %start.val, 1
  %calltmp = call i32 @std2__json__skip_ws(ptr %source.val6, i32 %addtmp)
  store i32 %calltmp, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %then4
  %i.val = load i32, ptr %i, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %cmptmp7 = icmp slt i32 %i.val, %end.val
  %2 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.addr8 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val9 = load ptr, ptr %source.addr8, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val10 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val9, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp11 = icmp eq i32 %string.expr.index.i32, 93
  %3 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %3, 0
  br i1 %ifcond12, label %then13, label %ifcont14

for.inc:                                          ; preds = %ifcont47
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %count.val48 = load i32, ptr %count, align 4
  call void @yc_frame_pop()
  ret i32 %count.val48

then13:                                           ; preds = %for.body
  %count.val = load i32, ptr %count, align 4
  call void @yc_frame_pop()
  ret i32 %count.val

ifcont14:                                         ; preds = %for.body
  %source.addr15 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val16 = load ptr, ptr %source.addr15, align 8
  %i.val17 = load i32, ptr %i, align 4
  %calltmp18 = call i32 @std2__json__value_end(ptr %source.val16, i32 %i.val17)
  store i32 %calltmp18, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp19 = icmp slt i32 %end_pos.val, 0
  %4 = zext i1 %cmptmp19 to i32
  %ifcond20 = icmp ne i32 %4, 0
  br i1 %ifcond20, label %then21, label %ifcont23

then21:                                           ; preds = %ifcont14
  %count.val22 = load i32, ptr %count, align 4
  call void @yc_frame_pop()
  ret i32 %count.val22

ifcont23:                                         ; preds = %ifcont14
  %compound.current = load i32, ptr %count, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %count, align 4
  %source.addr24 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val25 = load ptr, ptr %source.addr24, align 8
  %end_pos.val26 = load i32, ptr %end_pos, align 4
  %calltmp27 = call i32 @std2__json__skip_ws(ptr %source.val25, i32 %end_pos.val26)
  store i32 %calltmp27, ptr %i, align 4
  %i.val28 = load i32, ptr %i, align 4
  %end.addr29 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val30 = load i32, ptr %end.addr29, align 4
  %cmptmp31 = icmp slt i32 %i.val28, %end.val30
  %5 = zext i1 %cmptmp31 to i32
  %lhsbool = icmp ne i32 %5, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont23
  %source.addr32 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val33 = load ptr, ptr %source.addr32, align 8
  %i.val34 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6435 = sext i32 %i.val34 to i64
  %string.expr.index.ptr36 = getelementptr inbounds i8, ptr %source.val33, i64 %string.expr.index.ptr.idx.i6435
  %string.expr.index.load37 = load i8, ptr %string.expr.index.ptr36, align 1
  %string.expr.index.i3238 = zext i8 %string.expr.index.load37 to i32
  %cmptmp39 = icmp eq i32 %string.expr.index.i3238, 44
  %6 = zext i1 %cmptmp39 to i32
  %rhsbool = icmp ne i32 %6, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont23
  %landtmp = phi i1 [ false, %ifcont23 ], [ %rhsbool, %land.rhs ]
  %7 = zext i1 %landtmp to i32
  %ifcond40 = icmp ne i32 %7, 0
  br i1 %ifcond40, label %then41, label %ifcont47

then41:                                           ; preds = %land.end
  %source.addr42 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val43 = load ptr, ptr %source.addr42, align 8
  %i.val44 = load i32, ptr %i, align 4
  %addtmp45 = add i32 %i.val44, 1
  %calltmp46 = call i32 @std2__json__skip_ws(ptr %source.val43, i32 %addtmp45)
  store i32 %calltmp46, ptr %i, align 4
  br label %ifcont47

ifcont47:                                         ; preds = %then41, %land.end
  br label %for.inc

ifcont49:                                         ; preds = %ifcont
  %kind.addr50 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val51 = load i32, ptr %kind.addr50, align 4
  %cmptmp52 = icmp eq i32 %kind.val51, 1
  %8 = zext i1 %cmptmp52 to i32
  %ifcond53 = icmp ne i32 %8, 0
  br i1 %ifcond53, label %then54, label %ifcont142

then54:                                           ; preds = %ifcont49
  store i32 0, ptr %count55, align 4
  %source.addr56 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val57 = load ptr, ptr %source.addr56, align 8
  %start.addr58 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val59 = load i32, ptr %start.addr58, align 4
  %addtmp60 = add i32 %start.val59, 1
  %calltmp61 = call i32 @std2__json__skip_ws(ptr %source.val57, i32 %addtmp60)
  store i32 %calltmp61, ptr %i62, align 4
  br label %for.cond63

for.cond63:                                       ; preds = %for.inc65, %then54
  %i.val67 = load i32, ptr %i62, align 4
  %end.addr68 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val69 = load i32, ptr %end.addr68, align 4
  %cmptmp70 = icmp slt i32 %i.val67, %end.val69
  %9 = zext i1 %cmptmp70 to i32
  %forcond71 = icmp ne i32 %9, 0
  br i1 %forcond71, label %for.body64, label %for.after66

for.body64:                                       ; preds = %for.cond63
  %source.addr72 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val73 = load ptr, ptr %source.addr72, align 8
  %i.val74 = load i32, ptr %i62, align 4
  %string.expr.index.ptr.idx.i6475 = sext i32 %i.val74 to i64
  %string.expr.index.ptr76 = getelementptr inbounds i8, ptr %source.val73, i64 %string.expr.index.ptr.idx.i6475
  %string.expr.index.load77 = load i8, ptr %string.expr.index.ptr76, align 1
  %string.expr.index.i3278 = zext i8 %string.expr.index.load77 to i32
  %cmptmp79 = icmp eq i32 %string.expr.index.i3278, 125
  %10 = zext i1 %cmptmp79 to i32
  %ifcond80 = icmp ne i32 %10, 0
  br i1 %ifcond80, label %then81, label %ifcont83

for.inc65:                                        ; preds = %ifcont140
  br label %for.cond63

for.after66:                                      ; preds = %for.cond63
  %count.val141 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val141

then81:                                           ; preds = %for.body64
  %count.val82 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val82

ifcont83:                                         ; preds = %for.body64
  %source.addr84 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val85 = load ptr, ptr %source.addr84, align 8
  %i.val86 = load i32, ptr %i62, align 4
  %calltmp87 = call i32 @std2__json__string_end(ptr %source.val85, i32 %i.val86)
  store i32 %calltmp87, ptr %key_end, align 4
  %key_end.val = load i32, ptr %key_end, align 4
  %cmptmp88 = icmp slt i32 %key_end.val, 0
  %11 = zext i1 %cmptmp88 to i32
  %ifcond89 = icmp ne i32 %11, 0
  br i1 %ifcond89, label %then90, label %ifcont92

then90:                                           ; preds = %ifcont83
  %count.val91 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val91

ifcont92:                                         ; preds = %ifcont83
  %source.addr93 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val94 = load ptr, ptr %source.addr93, align 8
  %key_end.val95 = load i32, ptr %key_end, align 4
  %addtmp96 = add i32 %key_end.val95, 1
  %calltmp97 = call i32 @std2__json__skip_ws(ptr %source.val94, i32 %addtmp96)
  store i32 %calltmp97, ptr %after_key, align 4
  %source.addr98 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val99 = load ptr, ptr %source.addr98, align 8
  %after_key.val = load i32, ptr %after_key, align 4
  %addtmp100 = add i32 %after_key.val, 1
  %calltmp101 = call i32 @std2__json__skip_ws(ptr %source.val99, i32 %addtmp100)
  store i32 %calltmp101, ptr %value_start, align 4
  %source.addr102 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val103 = load ptr, ptr %source.addr102, align 8
  %value_start.val = load i32, ptr %value_start, align 4
  %calltmp104 = call i32 @std2__json__value_end(ptr %source.val103, i32 %value_start.val)
  store i32 %calltmp104, ptr %value_stop, align 4
  %value_stop.val = load i32, ptr %value_stop, align 4
  %cmptmp105 = icmp slt i32 %value_stop.val, 0
  %12 = zext i1 %cmptmp105 to i32
  %ifcond106 = icmp ne i32 %12, 0
  br i1 %ifcond106, label %then107, label %ifcont109

then107:                                          ; preds = %ifcont92
  %count.val108 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val108

ifcont109:                                        ; preds = %ifcont92
  %compound.current110 = load i32, ptr %count55, align 4
  %compound.add111 = add i32 %compound.current110, 1
  store i32 %compound.add111, ptr %count55, align 4
  %source.addr112 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val113 = load ptr, ptr %source.addr112, align 8
  %value_stop.val114 = load i32, ptr %value_stop, align 4
  %calltmp115 = call i32 @std2__json__skip_ws(ptr %source.val113, i32 %value_stop.val114)
  store i32 %calltmp115, ptr %i62, align 4
  %i.val118 = load i32, ptr %i62, align 4
  %end.addr119 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val120 = load i32, ptr %end.addr119, align 4
  %cmptmp121 = icmp slt i32 %i.val118, %end.val120
  %13 = zext i1 %cmptmp121 to i32
  %lhsbool122 = icmp ne i32 %13, 0
  br i1 %lhsbool122, label %land.rhs116, label %land.end117

land.rhs116:                                      ; preds = %ifcont109
  %source.addr123 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val124 = load ptr, ptr %source.addr123, align 8
  %i.val125 = load i32, ptr %i62, align 4
  %string.expr.index.ptr.idx.i64126 = sext i32 %i.val125 to i64
  %string.expr.index.ptr127 = getelementptr inbounds i8, ptr %source.val124, i64 %string.expr.index.ptr.idx.i64126
  %string.expr.index.load128 = load i8, ptr %string.expr.index.ptr127, align 1
  %string.expr.index.i32129 = zext i8 %string.expr.index.load128 to i32
  %cmptmp130 = icmp eq i32 %string.expr.index.i32129, 44
  %14 = zext i1 %cmptmp130 to i32
  %rhsbool131 = icmp ne i32 %14, 0
  br label %land.end117

land.end117:                                      ; preds = %land.rhs116, %ifcont109
  %landtmp132 = phi i1 [ false, %ifcont109 ], [ %rhsbool131, %land.rhs116 ]
  %15 = zext i1 %landtmp132 to i32
  %ifcond133 = icmp ne i32 %15, 0
  br i1 %ifcond133, label %then134, label %ifcont140

then134:                                          ; preds = %land.end117
  %source.addr135 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val136 = load ptr, ptr %source.addr135, align 8
  %i.val137 = load i32, ptr %i62, align 4
  %addtmp138 = add i32 %i.val137, 1
  %calltmp139 = call i32 @std2__json__skip_ws(ptr %source.val136, i32 %addtmp138)
  store i32 %calltmp139, ptr %i62, align 4
  br label %ifcont140

ifcont140:                                        ; preds = %then134, %land.end117
  br label %for.inc65

ifcont142:                                        ; preds = %ifcont49
  call void @yc_frame_pop()
  ret i32 0
}

define void @std2__json__free(%JsonValue %value) {
entry:
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %owns.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 5
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond = icmp ne i1 %owns.val, false
  br i1 %ifcond, label %then, label %ifcont12

then:                                             ; preds = %entry
  %root.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 1
  %root.val = load ptr, ptr %root.addr, align 8
  %cmptmp = icmp ne ptr %root.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond2 = icmp ne i32 %0, 0
  br i1 %ifcond2, label %then3, label %else

then3:                                            ; preds = %then
  %root.addr4 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 1
  %root.val5 = load ptr, ptr %root.addr4, align 8
  call void @std2__mem__free(ptr %root.val5)
  br label %ifcont11

else:                                             ; preds = %then
  %source.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp6 = icmp ne ptr %source.val, null
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont

then8:                                            ; preds = %else
  %source.addr9 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val10 = load ptr, ptr %source.addr9, align 8
  call void @std2__mem__free(ptr %source.val10)
  br label %ifcont

ifcont:                                           ; preds = %then8, %else
  br label %ifcont11

ifcont11:                                         ; preds = %ifcont, %then3
  br label %ifcont12

ifcont12:                                         ; preds = %ifcont11, %entry
  call void @yc_frame_pop()
  ret void
}

define i1 @std2__json__method_is(ptr %message, ptr %method) {
entry:
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %method2 = alloca ptr, align 8
  store ptr %method, ptr %method2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %method.val = load ptr, ptr %method2, align 8
  %calltmp = call i1 @std2__text__contains(ptr %message.val, ptr %method.val)
  call void @yc_frame_pop()
  ret i1 %calltmp
}

define i32 @std2__json__field_value_start(ptr %message, ptr %key) {
entry:
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %key_pos = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std2__text__find(ptr %message.val, ptr %key.val)
  store i32 %calltmp, ptr %key_pos, align 4
  %key_pos.val = load i32, ptr %key_pos, align 4
  %cmptmp = icmp slt i32 %key_pos.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %key_pos.val3 = load i32, ptr %key_pos, align 4
  %key.val4 = load ptr, ptr %key2, align 8
  %calltmp5 = call i32 @std2__text__len(ptr %key.val4)
  %addtmp = add i32 %key_pos.val3, %calltmp5
  store i32 %addtmp, ptr %i, align 4
  %message.val6 = load ptr, ptr %message1, align 8
  %calltmp7 = call i32 @std2__text__len(ptr %message.val6)
  store i32 %calltmp7, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp8 = icmp slt i32 %i.val, %n.val
  %1 = zext i1 %cmptmp8 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val12 = load i32, ptr %i, align 4
  %n.val13 = load i32, ptr %n, align 4
  %cmptmp14 = icmp sge i32 %i.val12, %n.val13
  %2 = zext i1 %cmptmp14 to i32
  %ifcond15 = icmp ne i32 %2, 0
  br i1 %ifcond15, label %then16, label %ifcont17

land.rhs:                                         ; preds = %for.cond
  %message.val9 = load ptr, ptr %message1, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val10 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp11 = icmp ne i32 %string.index.i32, 58
  %3 = zext i1 %cmptmp11 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs ]
  %4 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %4, 0
  br i1 %forcond, label %for.body, label %for.after

then16:                                           ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1

ifcont17:                                         ; preds = %for.after
  %message.val18 = load ptr, ptr %message1, align 8
  %i.val19 = load i32, ptr %i, align 4
  %addtmp20 = add i32 %i.val19, 1
  %calltmp21 = call i32 @std2__json__skip_ws(ptr %message.val18, i32 %addtmp20)
  call void @yc_frame_pop()
  ret i32 %calltmp21
}

define i32 @std2__json__field_i32(ptr %message, ptr %key) {
entry:
  %value = alloca i32, align 4
  %sign = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std2__json__field_value_start(ptr %message.val, ptr %key.val)
  store i32 %calltmp, ptr %i, align 4
  %i.val = load i32, ptr %i, align 4
  %cmptmp = icmp slt i32 %i.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  %message.val3 = load ptr, ptr %message1, align 8
  %calltmp4 = call i32 @std2__text__len(ptr %message.val3)
  store i32 %calltmp4, ptr %n, align 4
  store i32 1, ptr %sign, align 4
  %i.val5 = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp6 = icmp slt i32 %i.val5, %n.val
  %1 = zext i1 %cmptmp6 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont
  %message.val7 = load ptr, ptr %message1, align 8
  %i.val8 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val8 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp9 = icmp eq i32 %string.index.i32, 45
  %2 = zext i1 %cmptmp9 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont
  %landtmp = phi i1 [ false, %ifcont ], [ %rhsbool, %land.rhs ]
  %3 = zext i1 %landtmp to i32
  %ifcond10 = icmp ne i32 %3, 0
  br i1 %ifcond10, label %then11, label %ifcont12

then11:                                           ; preds = %land.end
  store i32 -1, ptr %sign, align 4
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  br label %ifcont12

ifcont12:                                         ; preds = %then11, %land.end
  store i32 0, ptr %value, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont12
  %i.val17 = load i32, ptr %i, align 4
  %n.val18 = load i32, ptr %n, align 4
  %cmptmp19 = icmp slt i32 %i.val17, %n.val18
  %4 = zext i1 %cmptmp19 to i32
  %lhsbool20 = icmp ne i32 %4, 0
  br i1 %lhsbool20, label %land.rhs15, label %land.end16

for.body:                                         ; preds = %land.end14
  %value.val = load i32, ptr %value, align 4
  %multmp = mul i32 %value.val, 10
  %message.val42 = load ptr, ptr %message1, align 8
  %i.val43 = load i32, ptr %i, align 4
  %string.local.ptr44 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6445 = sext i32 %i.val43 to i64
  %string.index.ptr46 = getelementptr inbounds i8, ptr %string.local.ptr44, i64 %string.index.ptr.idx.i6445
  %string.index.load47 = load i8, ptr %string.index.ptr46, align 1
  %string.index.i3248 = zext i8 %string.index.load47 to i32
  %subtmp = sub i32 %string.index.i3248, 48
  %addtmp = add i32 %multmp, %subtmp
  store i32 %addtmp, ptr %value, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end14
  %value.val49 = load i32, ptr %value, align 4
  %sign.val = load i32, ptr %sign, align 4
  %multmp50 = mul i32 %value.val49, %sign.val
  call void @yc_frame_pop()
  ret i32 %multmp50

land.rhs13:                                       ; preds = %land.end16
  %message.val32 = load ptr, ptr %message1, align 8
  %i.val33 = load i32, ptr %i, align 4
  %string.local.ptr34 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6435 = sext i32 %i.val33 to i64
  %string.index.ptr36 = getelementptr inbounds i8, ptr %string.local.ptr34, i64 %string.index.ptr.idx.i6435
  %string.index.load37 = load i8, ptr %string.index.ptr36, align 1
  %string.index.i3238 = zext i8 %string.index.load37 to i32
  %cmptmp39 = icmp sle i32 %string.index.i3238, 57
  %5 = zext i1 %cmptmp39 to i32
  %rhsbool40 = icmp ne i32 %5, 0
  br label %land.end14

land.end14:                                       ; preds = %land.rhs13, %land.end16
  %landtmp41 = phi i1 [ false, %land.end16 ], [ %rhsbool40, %land.rhs13 ]
  %6 = zext i1 %landtmp41 to i32
  %forcond = icmp ne i32 %6, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs15:                                       ; preds = %for.cond
  %message.val21 = load ptr, ptr %message1, align 8
  %i.val22 = load i32, ptr %i, align 4
  %string.local.ptr23 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6424 = sext i32 %i.val22 to i64
  %string.index.ptr25 = getelementptr inbounds i8, ptr %string.local.ptr23, i64 %string.index.ptr.idx.i6424
  %string.index.load26 = load i8, ptr %string.index.ptr25, align 1
  %string.index.i3227 = zext i8 %string.index.load26 to i32
  %cmptmp28 = icmp sge i32 %string.index.i3227, 48
  %7 = zext i1 %cmptmp28 to i32
  %rhsbool29 = icmp ne i32 %7, 0
  br label %land.end16

land.end16:                                       ; preds = %land.rhs15, %for.cond
  %landtmp30 = phi i1 [ false, %for.cond ], [ %rhsbool29, %land.rhs15 ]
  %8 = zext i1 %landtmp30 to i32
  %lhsbool31 = icmp ne i32 %8, 0
  br i1 %lhsbool31, label %land.rhs13, label %land.end14
}

define i32 @std2__json__id_i32(ptr %message) {
entry:
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %calltmp = call i32 @std2__json__field_i32(ptr %message.val, ptr @.str.25)
  call void @yc_frame_pop()
  ret i32 %calltmp
}

define ptr @std2__json__field_string(ptr %message, ptr %key) {
entry:
  %end_pos = alloca i32, align 4
  %n = alloca i32, align 4
  %start = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std2__json__field_value_start(ptr %message.val, ptr %key.val)
  store i32 %calltmp, ptr %start, align 4
  %start.val = load i32, ptr %start, align 4
  %cmptmp = icmp slt i32 %start.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %message.val3 = load ptr, ptr %message1, align 8
  %calltmp4 = call i32 @std2__text__len(ptr %message.val3)
  store i32 %calltmp4, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %start.val5 = load i32, ptr %start, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp6 = icmp slt i32 %start.val5, %n.val
  %1 = zext i1 %cmptmp6 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %start, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %start, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %start.val10 = load i32, ptr %start, align 4
  %n.val11 = load i32, ptr %n, align 4
  %cmptmp12 = icmp sge i32 %start.val10, %n.val11
  %2 = zext i1 %cmptmp12 to i32
  %ifcond13 = icmp ne i32 %2, 0
  br i1 %ifcond13, label %then14, label %ifcont16

land.rhs:                                         ; preds = %for.cond
  %message.val7 = load ptr, ptr %message1, align 8
  %start.val8 = load i32, ptr %start, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %start.val8 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp9 = icmp ne i32 %string.index.i32, 34
  %3 = zext i1 %cmptmp9 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs ]
  %4 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %4, 0
  br i1 %forcond, label %for.body, label %for.after

then14:                                           ; preds = %for.after
  %runtime.move15 = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move15

ifcont16:                                         ; preds = %for.after
  %message.val17 = load ptr, ptr %message1, align 8
  %start.val18 = load i32, ptr %start, align 4
  %calltmp19 = call i32 @std2__json__string_end(ptr %message.val17, i32 %start.val18)
  store i32 %calltmp19, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp20 = icmp slt i32 %end_pos.val, 0
  %5 = zext i1 %cmptmp20 to i32
  %ifcond21 = icmp ne i32 %5, 0
  br i1 %ifcond21, label %then22, label %ifcont24

then22:                                           ; preds = %ifcont16
  %runtime.move23 = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move23

ifcont24:                                         ; preds = %ifcont16
  %message.val25 = load ptr, ptr %message1, align 8
  %start.val26 = load i32, ptr %start, align 4
  %end_pos.val27 = load i32, ptr %end_pos, align 4
  %addtmp = add i32 %end_pos.val27, 1
  %calltmp28 = call ptr @std2__json__decode_string_slice(ptr %message.val25, i32 %start.val26, i32 %addtmp)
  %runtime.move29 = call ptr @yc_move_to_parent(ptr %calltmp28)
  call void @yc_frame_pop()
  ret ptr %runtime.move29
}

define i1 @std2__json__method_name_is(ptr %message, ptr %name) {
entry:
  %ok = alloca i1, align 1
  %method = alloca ptr, align 8
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %name2 = alloca ptr, align 8
  store ptr %name, ptr %name2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %calltmp = call ptr @std2__json__field_string(ptr %message.val, ptr @.str.26)
  store ptr %calltmp, ptr %method, align 8
  %method.val = load ptr, ptr %method, align 8
  %cmptmp = icmp eq ptr %method.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  %method.val3 = load ptr, ptr %method, align 8
  %name.val = load ptr, ptr %name2, align 8
  %calltmp4 = call i1 @std2__str__eq(ptr %method.val3, ptr %name.val)
  store i1 %calltmp4, ptr %ok, align 1
  %method.val5 = load ptr, ptr %method, align 8
  call void @std2__mem__free(ptr %method.val5)
  %ok.val = load i1, ptr %ok, align 1
  call void @yc_frame_pop()
  ret i1 %ok.val
}

define i32 @std2__json__content_length_at(ptr %message, i32 %start) {
entry:
  %value = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %key = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std2__text__find_from(ptr %message.val, ptr @.str.27, i32 %start.val)
  store i32 %calltmp, ptr %key, align 4
  %key.val = load i32, ptr %key, align 4
  %cmptmp = icmp slt i32 %key.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %key.val3 = load i32, ptr %key, align 4
  %addtmp = add i32 %key.val3, 15
  store i32 %addtmp, ptr %i, align 4
  %message.val4 = load ptr, ptr %message1, align 8
  %calltmp5 = call i32 @std2__text__len(ptr %message.val4)
  store i32 %calltmp5, ptr %n, align 4
  %message.val6 = load ptr, ptr %message1, align 8
  %i.val = load i32, ptr %i, align 4
  %calltmp7 = call i32 @std2__json__skip_ws(ptr %message.val6, i32 %i.val)
  store i32 %calltmp7, ptr %i, align 4
  store i32 0, ptr %value, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val10 = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp11 = icmp slt i32 %i.val10, %n.val
  %1 = zext i1 %cmptmp11 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs8, label %land.end9

for.body:                                         ; preds = %land.end
  %value.val = load i32, ptr %value, align 4
  %multmp = mul i32 %value.val, 10
  %message.val26 = load ptr, ptr %message1, align 8
  %i.val27 = load i32, ptr %i, align 4
  %string.local.ptr28 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6429 = sext i32 %i.val27 to i64
  %string.index.ptr30 = getelementptr inbounds i8, ptr %string.local.ptr28, i64 %string.index.ptr.idx.i6429
  %string.index.load31 = load i8, ptr %string.index.ptr30, align 1
  %string.index.i3232 = zext i8 %string.index.load31 to i32
  %subtmp = sub i32 %string.index.i3232, 48
  %addtmp33 = add i32 %multmp, %subtmp
  store i32 %addtmp33, ptr %value, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %value.val34 = load i32, ptr %value, align 4
  call void @yc_frame_pop()
  ret i32 %value.val34

land.rhs:                                         ; preds = %land.end9
  %message.val16 = load ptr, ptr %message1, align 8
  %i.val17 = load i32, ptr %i, align 4
  %string.local.ptr18 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6419 = sext i32 %i.val17 to i64
  %string.index.ptr20 = getelementptr inbounds i8, ptr %string.local.ptr18, i64 %string.index.ptr.idx.i6419
  %string.index.load21 = load i8, ptr %string.index.ptr20, align 1
  %string.index.i3222 = zext i8 %string.index.load21 to i32
  %cmptmp23 = icmp sle i32 %string.index.i3222, 57
  %2 = zext i1 %cmptmp23 to i32
  %rhsbool24 = icmp ne i32 %2, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.end9
  %landtmp25 = phi i1 [ false, %land.end9 ], [ %rhsbool24, %land.rhs ]
  %3 = zext i1 %landtmp25 to i32
  %forcond = icmp ne i32 %3, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs8:                                        ; preds = %for.cond
  %message.val12 = load ptr, ptr %message1, align 8
  %i.val13 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val13 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp14 = icmp sge i32 %string.index.i32, 48
  %4 = zext i1 %cmptmp14 to i32
  %rhsbool = icmp ne i32 %4, 0
  br label %land.end9

land.end9:                                        ; preds = %land.rhs8, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs8 ]
  %5 = zext i1 %landtmp to i32
  %lhsbool15 = icmp ne i32 %5, 0
  br i1 %lhsbool15, label %land.rhs, label %land.end
}

define i32 @std2__json__digits_i32(i32 %value) {
entry:
  %value1 = alloca i32, align 4
  store i32 %value, ptr %value1, align 4
  call void @yc_frame_push()
  %value.val = load i32, ptr %value1, align 4
  %cmptmp = icmp slt i32 %value.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %value.val2 = load i32, ptr %value1, align 4
  %negtmp = sub i32 0, %value.val2
  %calltmp = call i32 @std2__json__digits_i32(i32 %negtmp)
  %addtmp = add i32 %calltmp, 1
  call void @yc_frame_pop()
  ret i32 %addtmp

ifcont:                                           ; preds = %entry
  %value.val3 = load i32, ptr %value1, align 4
  %cmptmp4 = icmp slt i32 %value.val3, 10
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %ifcont7

then6:                                            ; preds = %ifcont
  call void @yc_frame_pop()
  ret i32 1

ifcont7:                                          ; preds = %ifcont
  %value.val8 = load i32, ptr %value1, align 4
  %cmptmp9 = icmp slt i32 %value.val8, 100
  %2 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %2, 0
  br i1 %ifcond10, label %then11, label %ifcont12

then11:                                           ; preds = %ifcont7
  call void @yc_frame_pop()
  ret i32 2

ifcont12:                                         ; preds = %ifcont7
  %value.val13 = load i32, ptr %value1, align 4
  %cmptmp14 = icmp slt i32 %value.val13, 1000
  %3 = zext i1 %cmptmp14 to i32
  %ifcond15 = icmp ne i32 %3, 0
  br i1 %ifcond15, label %then16, label %ifcont17

then16:                                           ; preds = %ifcont12
  call void @yc_frame_pop()
  ret i32 3

ifcont17:                                         ; preds = %ifcont12
  %value.val18 = load i32, ptr %value1, align 4
  %cmptmp19 = icmp slt i32 %value.val18, 10000
  %4 = zext i1 %cmptmp19 to i32
  %ifcond20 = icmp ne i32 %4, 0
  br i1 %ifcond20, label %then21, label %ifcont22

then21:                                           ; preds = %ifcont17
  call void @yc_frame_pop()
  ret i32 4

ifcont22:                                         ; preds = %ifcont17
  call void @yc_frame_pop()
  ret i32 5
}

define i32 @std2__json__unclosed_block_comment_offset(ptr %source) {
entry:
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %start = alloca i32, align 4
  %open = alloca i1, align 1
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  store i32 0, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %subtmp = sub i32 %n.val, 1
  %cmptmp = icmp slt i32 %i.val, %subtmp
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %open.val = load i1, ptr %open, align 1
  %notcmp = icmp eq i1 %open.val, false
  %notext = zext i1 %notcmp to i32
  %lhsbool = icmp ne i32 %notext, 0
  br i1 %lhsbool, label %land.rhs2, label %land.end3

for.inc:                                          ; preds = %ifcont51
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %open.val52 = load i1, ptr %open, align 1
  %ifcond53 = icmp ne i1 %open.val52, false
  br i1 %ifcond53, label %then54, label %ifcont55

land.rhs:                                         ; preds = %land.end3
  %source.val8 = load ptr, ptr %source1, align 8
  %i.val9 = load i32, ptr %i, align 4
  %addtmp = add i32 %i.val9, 1
  %string.local.ptr10 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6411 = sext i32 %addtmp to i64
  %string.index.ptr12 = getelementptr inbounds i8, ptr %string.local.ptr10, i64 %string.index.ptr.idx.i6411
  %string.index.load13 = load i8, ptr %string.index.ptr12, align 1
  %string.index.i3214 = zext i8 %string.index.load13 to i32
  %cmptmp15 = icmp eq i32 %string.index.i3214, 42
  %1 = zext i1 %cmptmp15 to i32
  %rhsbool16 = icmp ne i32 %1, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.end3
  %landtmp17 = phi i1 [ false, %land.end3 ], [ %rhsbool16, %land.rhs ]
  %2 = zext i1 %landtmp17 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %else

land.rhs2:                                        ; preds = %for.body
  %source.val4 = load ptr, ptr %source1, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val5 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp6 = icmp eq i32 %string.index.i32, 47
  %3 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %land.end3

land.end3:                                        ; preds = %land.rhs2, %for.body
  %landtmp = phi i1 [ false, %for.body ], [ %rhsbool, %land.rhs2 ]
  %4 = zext i1 %landtmp to i32
  %lhsbool7 = icmp ne i32 %4, 0
  br i1 %lhsbool7, label %land.rhs, label %land.end

then:                                             ; preds = %land.end
  store i1 true, ptr %open, align 1
  %i.val18 = load i32, ptr %i, align 4
  store i32 %i.val18, ptr %start, align 4
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  br label %ifcont51

else:                                             ; preds = %land.end
  %open.val23 = load i1, ptr %open, align 1
  %lhsbool24 = icmp ne i1 %open.val23, false
  br i1 %lhsbool24, label %land.rhs21, label %land.end22

land.rhs19:                                       ; preds = %land.end22
  %source.val36 = load ptr, ptr %source1, align 8
  %i.val37 = load i32, ptr %i, align 4
  %addtmp38 = add i32 %i.val37, 1
  %string.local.ptr39 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6440 = sext i32 %addtmp38 to i64
  %string.index.ptr41 = getelementptr inbounds i8, ptr %string.local.ptr39, i64 %string.index.ptr.idx.i6440
  %string.index.load42 = load i8, ptr %string.index.ptr41, align 1
  %string.index.i3243 = zext i8 %string.index.load42 to i32
  %cmptmp44 = icmp eq i32 %string.index.i3243, 47
  %5 = zext i1 %cmptmp44 to i32
  %rhsbool45 = icmp ne i32 %5, 0
  br label %land.end20

land.end20:                                       ; preds = %land.rhs19, %land.end22
  %landtmp46 = phi i1 [ false, %land.end22 ], [ %rhsbool45, %land.rhs19 ]
  %6 = zext i1 %landtmp46 to i32
  %ifcond47 = icmp ne i32 %6, 0
  br i1 %ifcond47, label %then48, label %ifcont

land.rhs21:                                       ; preds = %else
  %source.val25 = load ptr, ptr %source1, align 8
  %i.val26 = load i32, ptr %i, align 4
  %string.local.ptr27 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6428 = sext i32 %i.val26 to i64
  %string.index.ptr29 = getelementptr inbounds i8, ptr %string.local.ptr27, i64 %string.index.ptr.idx.i6428
  %string.index.load30 = load i8, ptr %string.index.ptr29, align 1
  %string.index.i3231 = zext i8 %string.index.load30 to i32
  %cmptmp32 = icmp eq i32 %string.index.i3231, 42
  %7 = zext i1 %cmptmp32 to i32
  %rhsbool33 = icmp ne i32 %7, 0
  br label %land.end22

land.end22:                                       ; preds = %land.rhs21, %else
  %landtmp34 = phi i1 [ false, %else ], [ %rhsbool33, %land.rhs21 ]
  %8 = zext i1 %landtmp34 to i32
  %lhsbool35 = icmp ne i32 %8, 0
  br i1 %lhsbool35, label %land.rhs19, label %land.end20

then48:                                           ; preds = %land.end20
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  %compound.current49 = load i32, ptr %i, align 4
  %compound.add50 = add i32 %compound.current49, 1
  store i32 %compound.add50, ptr %i, align 4
  br label %ifcont

ifcont:                                           ; preds = %then48, %land.end20
  br label %ifcont51

ifcont51:                                         ; preds = %ifcont, %then
  br label %for.inc

then54:                                           ; preds = %for.after
  %start.val = load i32, ptr %start, align 4
  call void @yc_frame_pop()
  ret i32 %start.val

ifcont55:                                         ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1
}

define i32 @std2__json__unclosed_string_offset(ptr %source) {
entry:
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %escape = alloca i1, align 1
  %start = alloca i32, align 4
  %open = alloca i1, align 1
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  store i1 false, ptr %escape, align 1
  store i32 0, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val2 = load ptr, ptr %source1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %escape.val = load i1, ptr %escape, align 1
  %ifcond = icmp ne i1 %escape.val, false
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont18
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %open.val19 = load i1, ptr %open, align 1
  %ifcond20 = icmp ne i1 %open.val19, false
  br i1 %ifcond20, label %then21, label %ifcont22

then:                                             ; preds = %for.body
  store i1 false, ptr %escape, align 1
  br label %ifcont18

else:                                             ; preds = %for.body
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp4 = icmp eq i32 %ch.val, 92
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %else7

then6:                                            ; preds = %else
  store i1 true, ptr %escape, align 1
  br label %ifcont17

else7:                                            ; preds = %else
  %ch.val8 = load i32, ptr %ch, align 4
  %cmptmp9 = icmp eq i32 %ch.val8, 34
  %2 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %2, 0
  br i1 %ifcond10, label %then11, label %ifcont16

then11:                                           ; preds = %else7
  %open.val = load i1, ptr %open, align 1
  %ifcond12 = icmp ne i1 %open.val, false
  br i1 %ifcond12, label %then13, label %else14

then13:                                           ; preds = %then11
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  br label %ifcont

else14:                                           ; preds = %then11
  store i1 true, ptr %open, align 1
  %i.val15 = load i32, ptr %i, align 4
  store i32 %i.val15, ptr %start, align 4
  br label %ifcont

ifcont:                                           ; preds = %else14, %then13
  br label %ifcont16

ifcont16:                                         ; preds = %ifcont, %else7
  br label %ifcont17

ifcont17:                                         ; preds = %ifcont16, %then6
  br label %ifcont18

ifcont18:                                         ; preds = %ifcont17, %then
  br label %for.inc

then21:                                           ; preds = %for.after
  %start.val = load i32, ptr %start, align 4
  call void @yc_frame_pop()
  ret i32 %start.val

ifcont22:                                         ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1
}

define i32 @std2__json__unclosed_brace_offset(ptr %source) {
entry:
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %escape = alloca i1, align 1
  %in_string = alloca i1, align 1
  %first_open = alloca i32, align 4
  %depth = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  store i32 0, ptr %depth, align 4
  store i32 -1, ptr %first_open, align 4
  store i1 false, ptr %in_string, align 1
  store i1 false, ptr %escape, align 1
  store i32 0, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val2 = load ptr, ptr %source1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %escape.val = load i1, ptr %escape, align 1
  %ifcond = icmp ne i1 %escape.val, false
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont54
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %depth.val55 = load i32, ptr %depth, align 4
  %cmptmp56 = icmp ne i32 %depth.val55, 0
  %1 = zext i1 %cmptmp56 to i32
  %ifcond57 = icmp ne i32 %1, 0
  br i1 %ifcond57, label %then58, label %ifcont59

then:                                             ; preds = %for.body
  store i1 false, ptr %escape, align 1
  br label %ifcont54

else:                                             ; preds = %for.body
  %in_string.val = load i1, ptr %in_string, align 1
  %lhsbool = icmp ne i1 %in_string.val, false
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %else
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp4 = icmp eq i32 %ch.val, 92
  %2 = zext i1 %cmptmp4 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %else
  %landtmp = phi i1 [ false, %else ], [ %rhsbool, %land.rhs ]
  %3 = zext i1 %landtmp to i32
  %ifcond5 = icmp ne i32 %3, 0
  br i1 %ifcond5, label %then6, label %else7

then6:                                            ; preds = %land.end
  store i1 true, ptr %escape, align 1
  br label %ifcont53

else7:                                            ; preds = %land.end
  %ch.val8 = load i32, ptr %ch, align 4
  %cmptmp9 = icmp eq i32 %ch.val8, 34
  %4 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %4, 0
  br i1 %ifcond10, label %then11, label %else13

then11:                                           ; preds = %else7
  %in_string.val12 = load i1, ptr %in_string, align 1
  %notcmp = icmp eq i1 %in_string.val12, false
  %notext = zext i1 %notcmp to i32
  %assign_trunc = trunc i32 %notext to i1
  store i1 %assign_trunc, ptr %in_string, align 1
  br label %ifcont52

else13:                                           ; preds = %else7
  %in_string.val16 = load i1, ptr %in_string, align 1
  %notcmp17 = icmp eq i1 %in_string.val16, false
  %notext18 = zext i1 %notcmp17 to i32
  %lhsbool19 = icmp ne i32 %notext18, 0
  br i1 %lhsbool19, label %land.rhs14, label %land.end15

land.rhs14:                                       ; preds = %else13
  %ch.val20 = load i32, ptr %ch, align 4
  %cmptmp21 = icmp eq i32 %ch.val20, 123
  %5 = zext i1 %cmptmp21 to i32
  %rhsbool22 = icmp ne i32 %5, 0
  br label %land.end15

land.end15:                                       ; preds = %land.rhs14, %else13
  %landtmp23 = phi i1 [ false, %else13 ], [ %rhsbool22, %land.rhs14 ]
  %6 = zext i1 %landtmp23 to i32
  %ifcond24 = icmp ne i32 %6, 0
  br i1 %ifcond24, label %then25, label %else30

then25:                                           ; preds = %land.end15
  %depth.val = load i32, ptr %depth, align 4
  %cmptmp26 = icmp eq i32 %depth.val, 0
  %7 = zext i1 %cmptmp26 to i32
  %ifcond27 = icmp ne i32 %7, 0
  br i1 %ifcond27, label %then28, label %ifcont

then28:                                           ; preds = %then25
  %i.val29 = load i32, ptr %i, align 4
  store i32 %i.val29, ptr %first_open, align 4
  br label %ifcont

ifcont:                                           ; preds = %then28, %then25
  %compound.current = load i32, ptr %depth, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %depth, align 4
  br label %ifcont51

else30:                                           ; preds = %land.end15
  %in_string.val33 = load i1, ptr %in_string, align 1
  %notcmp34 = icmp eq i1 %in_string.val33, false
  %notext35 = zext i1 %notcmp34 to i32
  %lhsbool36 = icmp ne i32 %notext35, 0
  br i1 %lhsbool36, label %land.rhs31, label %land.end32

land.rhs31:                                       ; preds = %else30
  %ch.val37 = load i32, ptr %ch, align 4
  %cmptmp38 = icmp eq i32 %ch.val37, 125
  %8 = zext i1 %cmptmp38 to i32
  %rhsbool39 = icmp ne i32 %8, 0
  br label %land.end32

land.end32:                                       ; preds = %land.rhs31, %else30
  %landtmp40 = phi i1 [ false, %else30 ], [ %rhsbool39, %land.rhs31 ]
  %9 = zext i1 %landtmp40 to i32
  %ifcond41 = icmp ne i32 %9, 0
  br i1 %ifcond41, label %then42, label %ifcont50

then42:                                           ; preds = %land.end32
  %depth.val43 = load i32, ptr %depth, align 4
  %cmptmp44 = icmp eq i32 %depth.val43, 0
  %10 = zext i1 %cmptmp44 to i32
  %ifcond45 = icmp ne i32 %10, 0
  br i1 %ifcond45, label %then46, label %ifcont48

then46:                                           ; preds = %then42
  %i.val47 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val47

ifcont48:                                         ; preds = %then42
  %compound.current49 = load i32, ptr %depth, align 4
  %compound.sub = sub i32 %compound.current49, 1
  store i32 %compound.sub, ptr %depth, align 4
  br label %ifcont50

ifcont50:                                         ; preds = %ifcont48, %land.end32
  br label %ifcont51

ifcont51:                                         ; preds = %ifcont50, %ifcont
  br label %ifcont52

ifcont52:                                         ; preds = %ifcont51, %then11
  br label %ifcont53

ifcont53:                                         ; preds = %ifcont52, %then6
  br label %ifcont54

ifcont54:                                         ; preds = %ifcont53, %then
  br label %for.inc

then58:                                           ; preds = %for.after
  %first_open.val = load i32, ptr %first_open, align 4
  call void @yc_frame_pop()
  ret i32 %first_open.val

ifcont59:                                         ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1
}

define internal i1 @std2__json__looks_like_ident_start(i32 %ch) {
entry:
  %ch1 = alloca i32, align 4
  store i32 %ch, ptr %ch1, align 4
  call void @yc_frame_push()
  %ch.val = load i32, ptr %ch1, align 4
  %cmptmp = icmp sge i32 %ch.val, 97
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

lor.rhs:                                          ; preds = %lor.end3
  %ch.val18 = load i32, ptr %ch1, align 4
  %cmptmp19 = icmp eq i32 %ch.val18, 95
  %1 = zext i1 %cmptmp19 to i32
  %rhsbool20 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end3
  %lortmp21 = phi i1 [ true, %lor.end3 ], [ %rhsbool20, %lor.rhs ]
  %2 = zext i1 %lortmp21 to i32
  %return.intcast = trunc i32 %2 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast

lor.rhs2:                                         ; preds = %land.end
  %ch.val9 = load i32, ptr %ch1, align 4
  %cmptmp10 = icmp sge i32 %ch.val9, 65
  %3 = zext i1 %cmptmp10 to i32
  %lhsbool11 = icmp ne i32 %3, 0
  br i1 %lhsbool11, label %land.rhs7, label %land.end8

lor.end3:                                         ; preds = %land.end8, %land.end
  %lortmp = phi i1 [ true, %land.end ], [ %rhsbool16, %land.end8 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool17 = icmp ne i32 %4, 0
  br i1 %lhsbool17, label %lor.end, label %lor.rhs

land.rhs:                                         ; preds = %entry
  %ch.val4 = load i32, ptr %ch1, align 4
  %cmptmp5 = icmp sle i32 %ch.val4, 122
  %5 = zext i1 %cmptmp5 to i32
  %rhsbool = icmp ne i32 %5, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %landtmp = phi i1 [ false, %entry ], [ %rhsbool, %land.rhs ]
  %6 = zext i1 %landtmp to i32
  %lhsbool6 = icmp ne i32 %6, 0
  br i1 %lhsbool6, label %lor.end3, label %lor.rhs2

land.rhs7:                                        ; preds = %lor.rhs2
  %ch.val12 = load i32, ptr %ch1, align 4
  %cmptmp13 = icmp sle i32 %ch.val12, 90
  %7 = zext i1 %cmptmp13 to i32
  %rhsbool14 = icmp ne i32 %7, 0
  br label %land.end8

land.end8:                                        ; preds = %land.rhs7, %lor.rhs2
  %landtmp15 = phi i1 [ false, %lor.rhs2 ], [ %rhsbool14, %land.rhs7 ]
  %8 = zext i1 %landtmp15 to i32
  %rhsbool16 = icmp ne i32 %8, 0
  br label %lor.end3
}

define internal i1 @std2__json__has_word_before(ptr %source, i32 %pos, ptr %word) {
entry:
  %start = alloca i32, align 4
  %i = alloca i32, align 4
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %pos2 = alloca i32, align 4
  store i32 %pos, ptr %pos2, align 4
  %word3 = alloca ptr, align 8
  store ptr %word, ptr %word3, align 8
  call void @yc_frame_push()
  %word.val = load ptr, ptr %word3, align 8
  %calltmp = call i32 @std2__text__len(ptr %word.val)
  store i32 %calltmp, ptr %n, align 4
  %pos.val = load i32, ptr %pos2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %pos.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  %pos.val4 = load i32, ptr %pos2, align 4
  %n.val5 = load i32, ptr %n, align 4
  %subtmp = sub i32 %pos.val4, %n.val5
  store i32 %subtmp, ptr %start, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val6 = load i32, ptr %n, align 4
  %cmptmp7 = icmp slt i32 %i.val, %n.val6
  %1 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start, align 4
  %i.val8 = load i32, ptr %i, align 4
  %addtmp = add i32 %start.val, %i.val8
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %word.val9 = load ptr, ptr %word3, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.local.ptr11 = load ptr, ptr %word3, align 8
  %string.index.ptr.idx.i6412 = sext i32 %i.val10 to i64
  %string.index.ptr13 = getelementptr inbounds i8, ptr %string.local.ptr11, i64 %string.index.ptr.idx.i6412
  %string.index.load14 = load i8, ptr %string.index.ptr13, align 1
  %string.index.i3215 = zext i8 %string.index.load14 to i32
  %cmptmp16 = icmp ne i32 %string.index.i32, %string.index.i3215
  %2 = zext i1 %cmptmp16 to i32
  %ifcond17 = icmp ne i32 %2, 0
  br i1 %ifcond17, label %then18, label %ifcont19

for.inc:                                          ; preds = %ifcont19
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then18:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont19:                                         ; preds = %for.body
  br label %for.inc
}

define internal i32 @std2__json__skip_inline_ws(ptr %source, i32 %i) {
entry:
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %i2 = alloca i32, align 4
  store i32 %i, ptr %i2, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i2, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i2, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val16 = load i32, ptr %i2, align 4
  call void @yc_frame_pop()
  ret i32 %i.val16

land.rhs:                                         ; preds = %for.cond
  %source.val3 = load ptr, ptr %source1, align 8
  %i.val4 = load i32, ptr %i2, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val4 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp5 = icmp eq i32 %string.index.i32, 32
  %1 = zext i1 %cmptmp5 to i32
  %lhsbool6 = icmp ne i32 %1, 0
  br i1 %lhsbool6, label %lor.end, label %lor.rhs

land.end:                                         ; preds = %lor.end, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool15, %lor.end ]
  %2 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

lor.rhs:                                          ; preds = %land.rhs
  %source.val7 = load ptr, ptr %source1, align 8
  %i.val8 = load i32, ptr %i2, align 4
  %string.local.ptr9 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6410 = sext i32 %i.val8 to i64
  %string.index.ptr11 = getelementptr inbounds i8, ptr %string.local.ptr9, i64 %string.index.ptr.idx.i6410
  %string.index.load12 = load i8, ptr %string.index.ptr11, align 1
  %string.index.i3213 = zext i8 %string.index.load12 to i32
  %cmptmp14 = icmp eq i32 %string.index.i3213, 9
  %3 = zext i1 %cmptmp14 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %land.rhs
  %lortmp = phi i1 [ true, %land.rhs ], [ %rhsbool, %lor.rhs ]
  %4 = zext i1 %lortmp to i32
  %rhsbool15 = icmp ne i32 %4, 0
  br label %land.end
}

define i32 @std2__json__malformed_import_offset(ptr %source) {
entry:
  %alias_start = alloca i32, align 4
  %after = alloca i32, align 4
  %end_pos = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %pos = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__find(ptr %source.val, ptr @.str.28)
  store i32 %calltmp, ptr %pos, align 4
  %pos.val = load i32, ptr %pos, align 4
  %cmptmp = icmp slt i32 %pos.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %pos.val3 = load i32, ptr %pos, align 4
  %addtmp = add i32 %pos.val3, 7
  %calltmp4 = call i32 @std2__json__skip_ws(ptr %source.val2, i32 %addtmp)
  store i32 %calltmp4, ptr %i, align 4
  %source.val5 = load ptr, ptr %source1, align 8
  %calltmp6 = call i32 @std2__text__len(ptr %source.val5)
  store i32 %calltmp6, ptr %n, align 4
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp7 = icmp sge i32 %i.val, %n.val
  %1 = zext i1 %cmptmp7 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont
  %source.val8 = load ptr, ptr %source1, align 8
  %i.val9 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val9 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp10 = icmp ne i32 %string.index.i32, 34
  %2 = zext i1 %cmptmp10 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont
  %lortmp = phi i1 [ true, %ifcont ], [ %rhsbool, %lor.rhs ]
  %3 = zext i1 %lortmp to i32
  %ifcond11 = icmp ne i32 %3, 0
  br i1 %ifcond11, label %then12, label %ifcont14

then12:                                           ; preds = %lor.end
  %pos.val13 = load i32, ptr %pos, align 4
  call void @yc_frame_pop()
  ret i32 %pos.val13

ifcont14:                                         ; preds = %lor.end
  %source.val15 = load ptr, ptr %source1, align 8
  %i.val16 = load i32, ptr %i, align 4
  %calltmp17 = call i32 @std2__json__string_end(ptr %source.val15, i32 %i.val16)
  store i32 %calltmp17, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp18 = icmp slt i32 %end_pos.val, 0
  %4 = zext i1 %cmptmp18 to i32
  %ifcond19 = icmp ne i32 %4, 0
  br i1 %ifcond19, label %then20, label %ifcont22

then20:                                           ; preds = %ifcont14
  %i.val21 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val21

ifcont22:                                         ; preds = %ifcont14
  %source.val23 = load ptr, ptr %source1, align 8
  %end_pos.val24 = load i32, ptr %end_pos, align 4
  %addtmp25 = add i32 %end_pos.val24, 1
  %calltmp26 = call i32 @std2__json__skip_ws(ptr %source.val23, i32 %addtmp25)
  store i32 %calltmp26, ptr %after, align 4
  %after.val = load i32, ptr %after, align 4
  %n.val27 = load i32, ptr %n, align 4
  %cmptmp28 = icmp slt i32 %after.val, %n.val27
  %5 = zext i1 %cmptmp28 to i32
  %lhsbool29 = icmp ne i32 %5, 0
  br i1 %lhsbool29, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont22
  %source.val30 = load ptr, ptr %source1, align 8
  %after.val31 = load i32, ptr %after, align 4
  %string.local.ptr32 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6433 = sext i32 %after.val31 to i64
  %string.index.ptr34 = getelementptr inbounds i8, ptr %string.local.ptr32, i64 %string.index.ptr.idx.i6433
  %string.index.load35 = load i8, ptr %string.index.ptr34, align 1
  %string.index.i3236 = zext i8 %string.index.load35 to i32
  %cmptmp37 = icmp eq i32 %string.index.i3236, 97
  %6 = zext i1 %cmptmp37 to i32
  %rhsbool38 = icmp ne i32 %6, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont22
  %landtmp = phi i1 [ false, %ifcont22 ], [ %rhsbool38, %land.rhs ]
  %7 = zext i1 %landtmp to i32
  %ifcond39 = icmp ne i32 %7, 0
  br i1 %ifcond39, label %then40, label %ifcont86

then40:                                           ; preds = %land.end
  %after.val43 = load i32, ptr %after, align 4
  %addtmp44 = add i32 %after.val43, 1
  %n.val45 = load i32, ptr %n, align 4
  %cmptmp46 = icmp sge i32 %addtmp44, %n.val45
  %8 = zext i1 %cmptmp46 to i32
  %lhsbool47 = icmp ne i32 %8, 0
  br i1 %lhsbool47, label %lor.end42, label %lor.rhs41

lor.rhs41:                                        ; preds = %then40
  %source.val48 = load ptr, ptr %source1, align 8
  %after.val49 = load i32, ptr %after, align 4
  %addtmp50 = add i32 %after.val49, 1
  %string.local.ptr51 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6452 = sext i32 %addtmp50 to i64
  %string.index.ptr53 = getelementptr inbounds i8, ptr %string.local.ptr51, i64 %string.index.ptr.idx.i6452
  %string.index.load54 = load i8, ptr %string.index.ptr53, align 1
  %string.index.i3255 = zext i8 %string.index.load54 to i32
  %cmptmp56 = icmp ne i32 %string.index.i3255, 115
  %9 = zext i1 %cmptmp56 to i32
  %rhsbool57 = icmp ne i32 %9, 0
  br label %lor.end42

lor.end42:                                        ; preds = %lor.rhs41, %then40
  %lortmp58 = phi i1 [ true, %then40 ], [ %rhsbool57, %lor.rhs41 ]
  %10 = zext i1 %lortmp58 to i32
  %ifcond59 = icmp ne i32 %10, 0
  br i1 %ifcond59, label %then60, label %ifcont62

then60:                                           ; preds = %lor.end42
  %after.val61 = load i32, ptr %after, align 4
  call void @yc_frame_pop()
  ret i32 %after.val61

ifcont62:                                         ; preds = %lor.end42
  %source.val63 = load ptr, ptr %source1, align 8
  %after.val64 = load i32, ptr %after, align 4
  %addtmp65 = add i32 %after.val64, 2
  %calltmp66 = call i32 @std2__json__skip_inline_ws(ptr %source.val63, i32 %addtmp65)
  store i32 %calltmp66, ptr %alias_start, align 4
  %alias_start.val = load i32, ptr %alias_start, align 4
  %n.val69 = load i32, ptr %n, align 4
  %cmptmp70 = icmp sge i32 %alias_start.val, %n.val69
  %11 = zext i1 %cmptmp70 to i32
  %lhsbool71 = icmp ne i32 %11, 0
  br i1 %lhsbool71, label %lor.end68, label %lor.rhs67

lor.rhs67:                                        ; preds = %ifcont62
  %source.val72 = load ptr, ptr %source1, align 8
  %alias_start.val73 = load i32, ptr %alias_start, align 4
  %string.local.ptr74 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6475 = sext i32 %alias_start.val73 to i64
  %string.index.ptr76 = getelementptr inbounds i8, ptr %string.local.ptr74, i64 %string.index.ptr.idx.i6475
  %string.index.load77 = load i8, ptr %string.index.ptr76, align 1
  %string.index.i3278 = zext i8 %string.index.load77 to i32
  %calltmp79 = call i1 @std2__json__looks_like_ident_start(i32 %string.index.i3278)
  %notcmp = icmp eq i1 %calltmp79, false
  %notext = zext i1 %notcmp to i32
  %rhsbool80 = icmp ne i32 %notext, 0
  br label %lor.end68

lor.end68:                                        ; preds = %lor.rhs67, %ifcont62
  %lortmp81 = phi i1 [ true, %ifcont62 ], [ %rhsbool80, %lor.rhs67 ]
  %12 = zext i1 %lortmp81 to i32
  %ifcond82 = icmp ne i32 %12, 0
  br i1 %ifcond82, label %then83, label %ifcont85

then83:                                           ; preds = %lor.end68
  %after.val84 = load i32, ptr %after, align 4
  call void @yc_frame_pop()
  ret i32 %after.val84

ifcont85:                                         ; preds = %lor.end68
  br label %ifcont86

ifcont86:                                         ; preds = %ifcont85, %land.end
  call void @yc_frame_pop()
  ret i32 -1
}

define i32 @std2__json__malformed_function_offset(ptr %source) {
entry:
  %block = alloca i32, align 4
  %close_paren = alloca i32, align 4
  %open_paren = alloca i32, align 4
  %n = alloca i32, align 4
  %name_start = alloca i32, align 4
  %pos = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__text__find(ptr %source.val, ptr @.str.29)
  store i32 %calltmp, ptr %pos, align 4
  %pos.val = load i32, ptr %pos, align 4
  %cmptmp = icmp slt i32 %pos.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %pos.val3 = load i32, ptr %pos, align 4
  %calltmp4 = call i1 @std2__json__has_word_before(ptr %source.val2, i32 %pos.val3, ptr @.str.30)
  %lhsbool = icmp ne i1 %calltmp4, false
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont
  %source.val5 = load ptr, ptr %source1, align 8
  %pos.val6 = load i32, ptr %pos, align 4
  %calltmp7 = call i1 @std2__json__has_word_before(ptr %source.val5, i32 %pos.val6, ptr @.str.31)
  %rhsbool = icmp ne i1 %calltmp7, false
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont
  %lortmp = phi i1 [ true, %ifcont ], [ %rhsbool, %lor.rhs ]
  %1 = zext i1 %lortmp to i32
  %ifcond8 = icmp ne i32 %1, 0
  br i1 %ifcond8, label %then9, label %ifcont10

then9:                                            ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 -1

ifcont10:                                         ; preds = %lor.end
  %source.val11 = load ptr, ptr %source1, align 8
  %pos.val12 = load i32, ptr %pos, align 4
  %addtmp = add i32 %pos.val12, 3
  %calltmp13 = call i32 @std2__json__skip_ws(ptr %source.val11, i32 %addtmp)
  store i32 %calltmp13, ptr %name_start, align 4
  %source.val14 = load ptr, ptr %source1, align 8
  %calltmp15 = call i32 @std2__text__len(ptr %source.val14)
  store i32 %calltmp15, ptr %n, align 4
  %name_start.val = load i32, ptr %name_start, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp18 = icmp sge i32 %name_start.val, %n.val
  %2 = zext i1 %cmptmp18 to i32
  %lhsbool19 = icmp ne i32 %2, 0
  br i1 %lhsbool19, label %lor.end17, label %lor.rhs16

lor.rhs16:                                        ; preds = %ifcont10
  %source.val20 = load ptr, ptr %source1, align 8
  %name_start.val21 = load i32, ptr %name_start, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %name_start.val21 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %calltmp22 = call i1 @std2__json__looks_like_ident_start(i32 %string.index.i32)
  %notcmp = icmp eq i1 %calltmp22, false
  %notext = zext i1 %notcmp to i32
  %rhsbool23 = icmp ne i32 %notext, 0
  br label %lor.end17

lor.end17:                                        ; preds = %lor.rhs16, %ifcont10
  %lortmp24 = phi i1 [ true, %ifcont10 ], [ %rhsbool23, %lor.rhs16 ]
  %3 = zext i1 %lortmp24 to i32
  %ifcond25 = icmp ne i32 %3, 0
  br i1 %ifcond25, label %then26, label %ifcont28

then26:                                           ; preds = %lor.end17
  %pos.val27 = load i32, ptr %pos, align 4
  call void @yc_frame_pop()
  ret i32 %pos.val27

ifcont28:                                         ; preds = %lor.end17
  %source.val29 = load ptr, ptr %source1, align 8
  %name_start.val30 = load i32, ptr %name_start, align 4
  %calltmp31 = call i32 @std2__text__find_from(ptr %source.val29, ptr @.str.32, i32 %name_start.val30)
  store i32 %calltmp31, ptr %open_paren, align 4
  %open_paren.val = load i32, ptr %open_paren, align 4
  %cmptmp32 = icmp slt i32 %open_paren.val, 0
  %4 = zext i1 %cmptmp32 to i32
  %ifcond33 = icmp ne i32 %4, 0
  br i1 %ifcond33, label %then34, label %ifcont36

then34:                                           ; preds = %ifcont28
  %pos.val35 = load i32, ptr %pos, align 4
  call void @yc_frame_pop()
  ret i32 %pos.val35

ifcont36:                                         ; preds = %ifcont28
  %source.val37 = load ptr, ptr %source1, align 8
  %open_paren.val38 = load i32, ptr %open_paren, align 4
  %calltmp39 = call i32 @std2__text__find_from(ptr %source.val37, ptr @.str.33, i32 %open_paren.val38)
  store i32 %calltmp39, ptr %close_paren, align 4
  %close_paren.val = load i32, ptr %close_paren, align 4
  %cmptmp40 = icmp slt i32 %close_paren.val, 0
  %5 = zext i1 %cmptmp40 to i32
  %ifcond41 = icmp ne i32 %5, 0
  br i1 %ifcond41, label %then42, label %ifcont44

then42:                                           ; preds = %ifcont36
  %open_paren.val43 = load i32, ptr %open_paren, align 4
  call void @yc_frame_pop()
  ret i32 %open_paren.val43

ifcont44:                                         ; preds = %ifcont36
  %source.val45 = load ptr, ptr %source1, align 8
  %close_paren.val46 = load i32, ptr %close_paren, align 4
  %calltmp47 = call i32 @std2__text__find_from(ptr %source.val45, ptr @.str.34, i32 %close_paren.val46)
  store i32 %calltmp47, ptr %block, align 4
  %block.val = load i32, ptr %block, align 4
  %cmptmp48 = icmp slt i32 %block.val, 0
  %6 = zext i1 %cmptmp48 to i32
  %ifcond49 = icmp ne i32 %6, 0
  br i1 %ifcond49, label %then50, label %ifcont52

then50:                                           ; preds = %ifcont44
  %close_paren.val51 = load i32, ptr %close_paren, align 4
  call void @yc_frame_pop()
  ret i32 %close_paren.val51

ifcont52:                                         ; preds = %ifcont44
  call void @yc_frame_pop()
  ret i32 -1
}

define i1 @std2__json__has_unclosed_brace(ptr %source) {
entry:
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__json__unclosed_brace_offset(ptr %source.val)
  %cmptmp = icmp sge i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define i1 @std2__json__has_unclosed_string(ptr %source) {
entry:
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__json__unclosed_string_offset(ptr %source.val)
  %cmptmp = icmp sge i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define i32 @std2__json__syntax_error_kind(ptr %source) {
entry:
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__json__unclosed_block_comment_offset(ptr %source.val)
  %cmptmp = icmp sge i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 1

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %calltmp3 = call i32 @std2__json__unclosed_string_offset(ptr %source.val2)
  %cmptmp4 = icmp sge i32 %calltmp3, 0
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %ifcont7

then6:                                            ; preds = %ifcont
  call void @yc_frame_pop()
  ret i32 2

ifcont7:                                          ; preds = %ifcont
  %source.val8 = load ptr, ptr %source1, align 8
  %calltmp9 = call i32 @std2__json__unclosed_brace_offset(ptr %source.val8)
  %cmptmp10 = icmp sge i32 %calltmp9, 0
  %2 = zext i1 %cmptmp10 to i32
  %ifcond11 = icmp ne i32 %2, 0
  br i1 %ifcond11, label %then12, label %ifcont13

then12:                                           ; preds = %ifcont7
  call void @yc_frame_pop()
  ret i32 3

ifcont13:                                         ; preds = %ifcont7
  %source.val18 = load ptr, ptr %source1, align 8
  %calltmp19 = call i1 @std2__text__starts_with(ptr %source.val18, ptr @.str.35)
  %lhsbool = icmp ne i1 %calltmp19, false
  br i1 %lhsbool, label %lor.end17, label %lor.rhs16

lor.rhs:                                          ; preds = %lor.end15
  %source.val28 = load ptr, ptr %source1, align 8
  %calltmp29 = call i1 @std2__text__contains(ptr %source.val28, ptr @.str.38)
  %rhsbool30 = icmp ne i1 %calltmp29, false
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end15
  %lortmp31 = phi i1 [ true, %lor.end15 ], [ %rhsbool30, %lor.rhs ]
  %3 = zext i1 %lortmp31 to i32
  %ifcond32 = icmp ne i32 %3, 0
  br i1 %ifcond32, label %then33, label %ifcont34

lor.rhs14:                                        ; preds = %lor.end17
  %source.val23 = load ptr, ptr %source1, align 8
  %calltmp24 = call i1 @std2__text__contains(ptr %source.val23, ptr @.str.37)
  %rhsbool25 = icmp ne i1 %calltmp24, false
  br label %lor.end15

lor.end15:                                        ; preds = %lor.rhs14, %lor.end17
  %lortmp26 = phi i1 [ true, %lor.end17 ], [ %rhsbool25, %lor.rhs14 ]
  %4 = zext i1 %lortmp26 to i32
  %lhsbool27 = icmp ne i32 %4, 0
  br i1 %lhsbool27, label %lor.end, label %lor.rhs

lor.rhs16:                                        ; preds = %ifcont13
  %source.val20 = load ptr, ptr %source1, align 8
  %calltmp21 = call i1 @std2__text__starts_with(ptr %source.val20, ptr @.str.36)
  %rhsbool = icmp ne i1 %calltmp21, false
  br label %lor.end17

lor.end17:                                        ; preds = %lor.rhs16, %ifcont13
  %lortmp = phi i1 [ true, %ifcont13 ], [ %rhsbool, %lor.rhs16 ]
  %5 = zext i1 %lortmp to i32
  %lhsbool22 = icmp ne i32 %5, 0
  br i1 %lhsbool22, label %lor.end15, label %lor.rhs14

then33:                                           ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 4

ifcont34:                                         ; preds = %lor.end
  %source.val35 = load ptr, ptr %source1, align 8
  %calltmp36 = call i32 @std2__json__malformed_import_offset(ptr %source.val35)
  %cmptmp37 = icmp sge i32 %calltmp36, 0
  %6 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %6, 0
  br i1 %ifcond38, label %then39, label %ifcont40

then39:                                           ; preds = %ifcont34
  call void @yc_frame_pop()
  ret i32 5

ifcont40:                                         ; preds = %ifcont34
  %source.val41 = load ptr, ptr %source1, align 8
  %calltmp42 = call i32 @std2__json__malformed_function_offset(ptr %source.val41)
  %cmptmp43 = icmp sge i32 %calltmp42, 0
  %7 = zext i1 %cmptmp43 to i32
  %ifcond44 = icmp ne i32 %7, 0
  br i1 %ifcond44, label %then45, label %ifcont46

then45:                                           ; preds = %ifcont40
  call void @yc_frame_pop()
  ret i32 6

ifcont46:                                         ; preds = %ifcont40
  call void @yc_frame_pop()
  ret i32 0
}

define i32 @std2__json__syntax_error_offset(ptr %source, i32 %kind) {
entry:
  %direct = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %kind2 = alloca i32, align 4
  store i32 %kind, ptr %kind2, align 4
  call void @yc_frame_push()
  %kind.val = load i32, ptr %kind2, align 4
  %cmptmp = icmp eq i32 %kind.val, 1
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std2__json__unclosed_block_comment_offset(ptr %source.val)
  call void @yc_frame_pop()
  ret i32 %calltmp

ifcont:                                           ; preds = %entry
  %kind.val3 = load i32, ptr %kind2, align 4
  %cmptmp4 = icmp eq i32 %kind.val3, 2
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %ifcont9

then6:                                            ; preds = %ifcont
  %source.val7 = load ptr, ptr %source1, align 8
  %calltmp8 = call i32 @std2__json__unclosed_string_offset(ptr %source.val7)
  call void @yc_frame_pop()
  ret i32 %calltmp8

ifcont9:                                          ; preds = %ifcont
  %kind.val10 = load i32, ptr %kind2, align 4
  %cmptmp11 = icmp eq i32 %kind.val10, 3
  %2 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %2, 0
  br i1 %ifcond12, label %then13, label %ifcont16

then13:                                           ; preds = %ifcont9
  %source.val14 = load ptr, ptr %source1, align 8
  %calltmp15 = call i32 @std2__json__unclosed_brace_offset(ptr %source.val14)
  call void @yc_frame_pop()
  ret i32 %calltmp15

ifcont16:                                         ; preds = %ifcont9
  %source.val17 = load ptr, ptr %source1, align 8
  %calltmp18 = call i1 @std2__text__starts_with(ptr %source.val17, ptr @.str.39)
  %lhsbool = icmp ne i1 %calltmp18, false
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont16
  %source.val19 = load ptr, ptr %source1, align 8
  %calltmp20 = call i1 @std2__text__starts_with(ptr %source.val19, ptr @.str.40)
  %rhsbool = icmp ne i1 %calltmp20, false
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont16
  %lortmp = phi i1 [ true, %ifcont16 ], [ %rhsbool, %lor.rhs ]
  %3 = zext i1 %lortmp to i32
  %ifcond21 = icmp ne i32 %3, 0
  br i1 %ifcond21, label %then22, label %ifcont23

then22:                                           ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 0

ifcont23:                                         ; preds = %lor.end
  %source.val24 = load ptr, ptr %source1, align 8
  %calltmp25 = call i32 @std2__text__find(ptr %source.val24, ptr @.str.41)
  store i32 %calltmp25, ptr %direct, align 4
  %direct.val = load i32, ptr %direct, align 4
  %cmptmp26 = icmp sge i32 %direct.val, 0
  %4 = zext i1 %cmptmp26 to i32
  %ifcond27 = icmp ne i32 %4, 0
  br i1 %ifcond27, label %then28, label %ifcont30

then28:                                           ; preds = %ifcont23
  %direct.val29 = load i32, ptr %direct, align 4
  %addtmp = add i32 %direct.val29, 1
  call void @yc_frame_pop()
  ret i32 %addtmp

ifcont30:                                         ; preds = %ifcont23
  %source.val31 = load ptr, ptr %source1, align 8
  %calltmp32 = call i32 @std2__text__find(ptr %source.val31, ptr @.str.42)
  store i32 %calltmp32, ptr %direct, align 4
  %direct.val33 = load i32, ptr %direct, align 4
  %cmptmp34 = icmp sge i32 %direct.val33, 0
  %5 = zext i1 %cmptmp34 to i32
  %ifcond35 = icmp ne i32 %5, 0
  br i1 %ifcond35, label %then36, label %ifcont39

then36:                                           ; preds = %ifcont30
  %direct.val37 = load i32, ptr %direct, align 4
  %addtmp38 = add i32 %direct.val37, 1
  call void @yc_frame_pop()
  ret i32 %addtmp38

ifcont39:                                         ; preds = %ifcont30
  %kind.val40 = load i32, ptr %kind2, align 4
  %cmptmp41 = icmp eq i32 %kind.val40, 5
  %6 = zext i1 %cmptmp41 to i32
  %ifcond42 = icmp ne i32 %6, 0
  br i1 %ifcond42, label %then43, label %ifcont46

then43:                                           ; preds = %ifcont39
  %source.val44 = load ptr, ptr %source1, align 8
  %calltmp45 = call i32 @std2__json__malformed_import_offset(ptr %source.val44)
  call void @yc_frame_pop()
  ret i32 %calltmp45

ifcont46:                                         ; preds = %ifcont39
  %kind.val47 = load i32, ptr %kind2, align 4
  %cmptmp48 = icmp eq i32 %kind.val47, 6
  %7 = zext i1 %cmptmp48 to i32
  %ifcond49 = icmp ne i32 %7, 0
  br i1 %ifcond49, label %then50, label %ifcont53

then50:                                           ; preds = %ifcont46
  %source.val51 = load ptr, ptr %source1, align 8
  %calltmp52 = call i32 @std2__json__malformed_function_offset(ptr %source.val51)
  call void @yc_frame_pop()
  ret i32 %calltmp52

ifcont53:                                         ; preds = %ifcont46
  call void @yc_frame_pop()
  ret i32 0
}

define ptr @std2__json__syntax_error_message(i32 %kind) {
entry:
  %kind1 = alloca i32, align 4
  store i32 %kind, ptr %kind1, align 4
  call void @yc_frame_push()
  %kind.val = load i32, ptr %kind1, align 4
  %cmptmp = icmp eq i32 %kind.val, 1
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr @.str.43)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %kind.val2 = load i32, ptr %kind1, align 4
  %cmptmp3 = icmp eq i32 %kind.val2, 2
  %1 = zext i1 %cmptmp3 to i32
  %ifcond4 = icmp ne i32 %1, 0
  br i1 %ifcond4, label %then5, label %ifcont7

then5:                                            ; preds = %ifcont
  %runtime.move6 = call ptr @yc_move_to_parent(ptr @.str.44)
  call void @yc_frame_pop()
  ret ptr %runtime.move6

ifcont7:                                          ; preds = %ifcont
  %kind.val8 = load i32, ptr %kind1, align 4
  %cmptmp9 = icmp eq i32 %kind.val8, 3
  %2 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %2, 0
  br i1 %ifcond10, label %then11, label %ifcont13

then11:                                           ; preds = %ifcont7
  %runtime.move12 = call ptr @yc_move_to_parent(ptr @.str.45)
  call void @yc_frame_pop()
  ret ptr %runtime.move12

ifcont13:                                         ; preds = %ifcont7
  %kind.val14 = load i32, ptr %kind1, align 4
  %cmptmp15 = icmp eq i32 %kind.val14, 4
  %3 = zext i1 %cmptmp15 to i32
  %ifcond16 = icmp ne i32 %3, 0
  br i1 %ifcond16, label %then17, label %ifcont19

then17:                                           ; preds = %ifcont13
  %runtime.move18 = call ptr @yc_move_to_parent(ptr @.str.46)
  call void @yc_frame_pop()
  ret ptr %runtime.move18

ifcont19:                                         ; preds = %ifcont13
  %kind.val20 = load i32, ptr %kind1, align 4
  %cmptmp21 = icmp eq i32 %kind.val20, 5
  %4 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %4, 0
  br i1 %ifcond22, label %then23, label %ifcont25

then23:                                           ; preds = %ifcont19
  %runtime.move24 = call ptr @yc_move_to_parent(ptr @.str.47)
  call void @yc_frame_pop()
  ret ptr %runtime.move24

ifcont25:                                         ; preds = %ifcont19
  %kind.val26 = load i32, ptr %kind1, align 4
  %cmptmp27 = icmp eq i32 %kind.val26, 6
  %5 = zext i1 %cmptmp27 to i32
  %ifcond28 = icmp ne i32 %5, 0
  br i1 %ifcond28, label %then29, label %ifcont31

then29:                                           ; preds = %ifcont25
  %runtime.move30 = call ptr @yc_move_to_parent(ptr @.str.48)
  call void @yc_frame_pop()
  ret ptr %runtime.move30

ifcont31:                                         ; preds = %ifcont25
  %runtime.move32 = call ptr @yc_move_to_parent(ptr @.str.49)
  call void @yc_frame_pop()
  ret ptr %runtime.move32
}

declare i64 @strlen(ptr)

declare i32 @strcmp(ptr, ptr)

declare ptr @strcpy(ptr, ptr)

define i64 @std__str__len(ptr %s) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @strlen(ptr %s.val)
  call void @yc_frame_pop()
  ret i64 %calltmp
}

define i32 @std__str__cmp(ptr %a, ptr %b) {
entry:
  %a1 = alloca ptr, align 8
  store ptr %a, ptr %a1, align 8
  %b2 = alloca ptr, align 8
  store ptr %b, ptr %b2, align 8
  call void @yc_frame_push()
  %a.val = load ptr, ptr %a1, align 8
  %b.val = load ptr, ptr %b2, align 8
  %calltmp = call i32 @strcmp(ptr %a.val, ptr %b.val)
  call void @yc_frame_pop()
  ret i32 %calltmp
}

define ptr @std__str__copy(ptr %dst, ptr %src) {
entry:
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %src2 = alloca ptr, align 8
  store ptr %src, ptr %src2, align 8
  call void @yc_frame_push()
  %dst.val = load ptr, ptr %dst1, align 8
  %src.val = load ptr, ptr %src2, align 8
  %calltmp = call ptr @strcpy(ptr %dst.val, ptr %src.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define i1 @std__str__eq(ptr %a, ptr %b) {
entry:
  %a1 = alloca ptr, align 8
  store ptr %a, ptr %a1, align 8
  %b2 = alloca ptr, align 8
  store ptr %b, ptr %b2, align 8
  call void @yc_frame_push()
  %a.val = load ptr, ptr %a1, align 8
  %b.val = load ptr, ptr %b2, align 8
  %calltmp = call i32 @strcmp(ptr %a.val, ptr %b.val)
  %cmptmp = icmp eq i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

declare ptr @yc_alloc(i64)

declare ptr @yc_calloc(i64, i64)

declare ptr @yc_realloc(ptr, i64)

declare void @yc_release(ptr)

declare void @yc_attach_child(ptr, ptr)

declare void @yc_replace_child(ptr, ptr, ptr)

declare ptr @yc_move_to_root(ptr)

declare ptr @yc_keep_string(ptr)

declare ptr @memset(ptr, i32, i64)

define ptr @std2__mem__alloc(i64 %size) {
entry:
  %size1 = alloca i64, align 8
  store i64 %size, ptr %size1, align 4
  call void @yc_frame_push()
  %size.val = load i64, ptr %size1, align 4
  %calltmp = call ptr @yc_alloc(i64 %size.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define ptr @std2__mem__calloc(i64 %count, i64 %size) {
entry:
  %count1 = alloca i64, align 8
  store i64 %count, ptr %count1, align 4
  %size2 = alloca i64, align 8
  store i64 %size, ptr %size2, align 4
  call void @yc_frame_push()
  %count.val = load i64, ptr %count1, align 4
  %size.val = load i64, ptr %size2, align 4
  %calltmp = call ptr @yc_calloc(i64 %count.val, i64 %size.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define ptr @std2__mem__realloc(ptr %ptr, i64 %size) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  %size2 = alloca i64, align 8
  store i64 %size, ptr %size2, align 4
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  %size.val = load i64, ptr %size2, align 4
  %calltmp = call ptr @yc_realloc(ptr %ptr.val, i64 %size.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std2__mem__free(ptr %ptr) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  call void @yc_release(ptr %ptr.val)
  call void @yc_frame_pop()
  ret void
}

define void @std2__mem__attach_child(ptr %parent, ptr %child) {
entry:
  %parent1 = alloca ptr, align 8
  store ptr %parent, ptr %parent1, align 8
  %child2 = alloca ptr, align 8
  store ptr %child, ptr %child2, align 8
  call void @yc_frame_push()
  %parent.val = load ptr, ptr %parent1, align 8
  %child.val = load ptr, ptr %child2, align 8
  call void @yc_attach_child(ptr %parent.val, ptr %child.val)
  call void @yc_frame_pop()
  ret void
}

define void @std2__mem__replace_child(ptr %parent, ptr %old_child, ptr %new_child) {
entry:
  %parent1 = alloca ptr, align 8
  store ptr %parent, ptr %parent1, align 8
  %old_child2 = alloca ptr, align 8
  store ptr %old_child, ptr %old_child2, align 8
  %new_child3 = alloca ptr, align 8
  store ptr %new_child, ptr %new_child3, align 8
  call void @yc_frame_push()
  %parent.val = load ptr, ptr %parent1, align 8
  %old_child.val = load ptr, ptr %old_child2, align 8
  %new_child.val = load ptr, ptr %new_child3, align 8
  call void @yc_replace_child(ptr %parent.val, ptr %old_child.val, ptr %new_child.val)
  call void @yc_frame_pop()
  ret void
}

define ptr @std2__mem__keep(ptr %ptr) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  %calltmp = call ptr @yc_move_to_root(ptr %ptr.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define ptr @std2__mem__keep_string(ptr %ptr) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  %calltmp = call ptr @yc_keep_string(ptr %ptr.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std2__mem__copy(ptr %dst, ptr %src, i64 %size) {
entry:
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %src2 = alloca ptr, align 8
  store ptr %src, ptr %src2, align 8
  %size3 = alloca i64, align 8
  store i64 %size, ptr %size3, align 4
  call void @yc_frame_push()
  %dst.val = load ptr, ptr %dst1, align 8
  %src.val = load ptr, ptr %src2, align 8
  %size.val = load i64, ptr %size3, align 4
  %calltmp = call ptr @memcpy(ptr %dst.val, ptr %src.val, i64 %size.val)
  call void @yc_frame_pop()
  ret void
}

define void @std2__mem__set(ptr %dst, i32 %value, i64 %size) {
entry:
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %value2 = alloca i32, align 4
  store i32 %value, ptr %value2, align 4
  %size3 = alloca i64, align 8
  store i64 %size, ptr %size3, align 4
  call void @yc_frame_push()
  %dst.val = load ptr, ptr %dst1, align 8
  %value.val = load i32, ptr %value2, align 4
  %size.val = load i64, ptr %size3, align 4
  %calltmp = call ptr @memset(ptr %dst.val, i32 %value.val, i64 %size.val)
  call void @yc_frame_pop()
  ret void
}

define i32 @std__text__len(ptr %s) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std__str__len(ptr %s.val)
  %return.intcast = trunc i64 %calltmp to i32
  call void @yc_frame_pop()
  ret i32 %return.intcast
}

define i1 @std__text__contains(ptr %s, ptr %needle) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %needle2 = alloca ptr, align 8
  store ptr %needle, ptr %needle2, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %needle.val = load ptr, ptr %needle2, align 8
  %calltmp = call ptr @strstr(ptr %s.val, ptr %needle.val)
  %cmptmp = icmp ne ptr %calltmp, null
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define i1 @std__text__starts_with(ptr %s, ptr %prefix) {
entry:
  %n = alloca i64, align 8
  %i = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %prefix2 = alloca ptr, align 8
  store ptr %prefix, ptr %prefix2, align 8
  call void @yc_frame_push()
  store i32 0, ptr %i, align 4
  %prefix.val = load ptr, ptr %prefix2, align 8
  %calltmp = call i64 @std__str__len(ptr %prefix.val)
  store i64 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %0 = sext i32 %i.val to i64
  %cmptmp = icmp slt i64 %0, %n.val
  %1 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val = load ptr, ptr %s1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %prefix.val4 = load ptr, ptr %prefix2, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.local.ptr6 = load ptr, ptr %prefix2, align 8
  %string.index.ptr.idx.i647 = sext i32 %i.val5 to i64
  %string.index.ptr8 = getelementptr inbounds i8, ptr %string.local.ptr6, i64 %string.index.ptr.idx.i647
  %string.index.load9 = load i8, ptr %string.index.ptr8, align 1
  %string.index.i3210 = zext i8 %string.index.load9 to i32
  %cmptmp11 = icmp ne i32 %string.index.i32, %string.index.i3210
  %2 = zext i1 %cmptmp11 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then:                                             ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %for.body
  br label %for.inc
}

define i32 @std__text__find(ptr %s, ptr %needle) {
entry:
  %j = alloca i32, align 4
  %ok = alloca i1, align 1
  %i = alloca i32, align 4
  %m = alloca i64, align 8
  %n = alloca i64, align 8
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %needle2 = alloca ptr, align 8
  store ptr %needle, ptr %needle2, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std__str__len(ptr %s.val)
  store i64 %calltmp, ptr %n, align 4
  %needle.val = load ptr, ptr %needle2, align 8
  %calltmp3 = call i64 @std__str__len(ptr %needle.val)
  store i64 %calltmp3, ptr %m, align 4
  %m.val = load i64, ptr %m, align 4
  %cmptmp = icmp eq i64 %m.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %m.val4 = load i64, ptr %m, align 4
  %subtmp = sub i64 %n.val, %m.val4
  %1 = sext i32 %i.val to i64
  %cmptmp5 = icmp sle i64 %1, %subtmp
  %2 = zext i1 %cmptmp5 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  store i1 true, ptr %ok, align 1
  store i32 0, ptr %j, align 4
  br label %for.cond6

for.inc:                                          ; preds = %ifcont30
  %post_old31 = load i32, ptr %i, align 4
  %post_inc32 = add i32 %post_old31, 1
  store i32 %post_inc32, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

for.cond6:                                        ; preds = %for.inc8, %for.body
  %j.val = load i32, ptr %j, align 4
  %m.val10 = load i64, ptr %m, align 4
  %3 = sext i32 %j.val to i64
  %cmptmp11 = icmp slt i64 %3, %m.val10
  %4 = zext i1 %cmptmp11 to i32
  %forcond12 = icmp ne i32 %4, 0
  br i1 %forcond12, label %for.body7, label %for.after9

for.body7:                                        ; preds = %for.cond6
  %s.val13 = load ptr, ptr %s1, align 8
  %i.val14 = load i32, ptr %i, align 4
  %j.val15 = load i32, ptr %j, align 4
  %addtmp = add i32 %i.val14, %j.val15
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %needle.val16 = load ptr, ptr %needle2, align 8
  %j.val17 = load i32, ptr %j, align 4
  %string.local.ptr18 = load ptr, ptr %needle2, align 8
  %string.index.ptr.idx.i6419 = sext i32 %j.val17 to i64
  %string.index.ptr20 = getelementptr inbounds i8, ptr %string.local.ptr18, i64 %string.index.ptr.idx.i6419
  %string.index.load21 = load i8, ptr %string.index.ptr20, align 1
  %string.index.i3222 = zext i8 %string.index.load21 to i32
  %cmptmp23 = icmp ne i32 %string.index.i32, %string.index.i3222
  %5 = zext i1 %cmptmp23 to i32
  %ifcond24 = icmp ne i32 %5, 0
  br i1 %ifcond24, label %then25, label %ifcont26

for.inc8:                                         ; preds = %ifcont26
  %post_old = load i32, ptr %j, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %j, align 4
  br label %for.cond6

for.after9:                                       ; preds = %for.cond6
  %ok.val = load i1, ptr %ok, align 1
  %ifcond27 = icmp ne i1 %ok.val, false
  br i1 %ifcond27, label %then28, label %ifcont30

then25:                                           ; preds = %for.body7
  store i1 false, ptr %ok, align 1
  br label %ifcont26

ifcont26:                                         ; preds = %then25, %for.body7
  br label %for.inc8

then28:                                           ; preds = %for.after9
  %i.val29 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val29

ifcont30:                                         ; preds = %for.after9
  br label %for.inc
}

define i32 @std__text__find_from(ptr %s, ptr %needle, i32 %start) {
entry:
  %j = alloca i32, align 4
  %ok = alloca i1, align 1
  %i = alloca i32, align 4
  %m = alloca i64, align 8
  %n = alloca i64, align 8
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %needle2 = alloca ptr, align 8
  store ptr %needle, ptr %needle2, align 8
  %start3 = alloca i32, align 4
  store i32 %start, ptr %start3, align 4
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std__str__len(ptr %s.val)
  store i64 %calltmp, ptr %n, align 4
  %needle.val = load ptr, ptr %needle2, align 8
  %calltmp4 = call i64 @std__str__len(ptr %needle.val)
  store i64 %calltmp4, ptr %m, align 4
  %m.val = load i64, ptr %m, align 4
  %cmptmp = icmp eq i64 %m.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %start.val = load i32, ptr %start3, align 4
  call void @yc_frame_pop()
  ret i32 %start.val

ifcont:                                           ; preds = %entry
  %start.val5 = load i32, ptr %start3, align 4
  store i32 %start.val5, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %m.val6 = load i64, ptr %m, align 4
  %subtmp = sub i64 %n.val, %m.val6
  %1 = sext i32 %i.val to i64
  %cmptmp7 = icmp sle i64 %1, %subtmp
  %2 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  store i1 true, ptr %ok, align 1
  store i32 0, ptr %j, align 4
  br label %for.cond8

for.inc:                                          ; preds = %ifcont32
  %post_old33 = load i32, ptr %i, align 4
  %post_inc34 = add i32 %post_old33, 1
  store i32 %post_inc34, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

for.cond8:                                        ; preds = %for.inc10, %for.body
  %j.val = load i32, ptr %j, align 4
  %m.val12 = load i64, ptr %m, align 4
  %3 = sext i32 %j.val to i64
  %cmptmp13 = icmp slt i64 %3, %m.val12
  %4 = zext i1 %cmptmp13 to i32
  %forcond14 = icmp ne i32 %4, 0
  br i1 %forcond14, label %for.body9, label %for.after11

for.body9:                                        ; preds = %for.cond8
  %s.val15 = load ptr, ptr %s1, align 8
  %i.val16 = load i32, ptr %i, align 4
  %j.val17 = load i32, ptr %j, align 4
  %addtmp = add i32 %i.val16, %j.val17
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %needle.val18 = load ptr, ptr %needle2, align 8
  %j.val19 = load i32, ptr %j, align 4
  %string.local.ptr20 = load ptr, ptr %needle2, align 8
  %string.index.ptr.idx.i6421 = sext i32 %j.val19 to i64
  %string.index.ptr22 = getelementptr inbounds i8, ptr %string.local.ptr20, i64 %string.index.ptr.idx.i6421
  %string.index.load23 = load i8, ptr %string.index.ptr22, align 1
  %string.index.i3224 = zext i8 %string.index.load23 to i32
  %cmptmp25 = icmp ne i32 %string.index.i32, %string.index.i3224
  %5 = zext i1 %cmptmp25 to i32
  %ifcond26 = icmp ne i32 %5, 0
  br i1 %ifcond26, label %then27, label %ifcont28

for.inc10:                                        ; preds = %ifcont28
  %post_old = load i32, ptr %j, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %j, align 4
  br label %for.cond8

for.after11:                                      ; preds = %for.cond8
  %ok.val = load i1, ptr %ok, align 1
  %ifcond29 = icmp ne i1 %ok.val, false
  br i1 %ifcond29, label %then30, label %ifcont32

then27:                                           ; preds = %for.body9
  store i1 false, ptr %ok, align 1
  br label %ifcont28

ifcont28:                                         ; preds = %then27, %for.body9
  br label %for.inc10

then30:                                           ; preds = %for.after11
  %i.val31 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val31

ifcont32:                                         ; preds = %for.after11
  br label %for.inc
}

define ptr @std__text__slice(ptr %s, i32 %start, i32 %count) {
entry:
  %i = alloca i32, align 4
  %out = alloca ptr, align 8
  %n = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %count3 = alloca i32, align 4
  store i32 %count, ptr %count3, align 4
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %cmptmp = icmp eq ptr %s.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end5, label %lor.rhs4

lor.rhs:                                          ; preds = %lor.end5
  %count.val = load i32, ptr %count3, align 4
  %cmptmp8 = icmp slt i32 %count.val, 0
  %1 = zext i1 %cmptmp8 to i32
  %rhsbool9 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp10 = phi i1 [ true, %lor.end5 ], [ %rhsbool9, %lor.rhs ]
  %2 = zext i1 %lortmp10 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %entry
  %start.val = load i32, ptr %start2, align 4
  %cmptmp6 = icmp slt i32 %start.val, 0
  %3 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs4 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool7 = icmp ne i32 %4, 0
  br i1 %lhsbool7, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %lor.end
  %s.val11 = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std__str__len(ptr %s.val11)
  %5 = trunc i64 %calltmp to i32
  store i32 %5, ptr %n, align 4
  %start.val12 = load i32, ptr %start2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp13 = icmp sgt i32 %start.val12, %n.val
  %6 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %6, 0
  br i1 %ifcond14, label %then15, label %ifcont17

then15:                                           ; preds = %ifcont
  %runtime.move16 = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move16

ifcont17:                                         ; preds = %ifcont
  %start.val18 = load i32, ptr %start2, align 4
  %count.val19 = load i32, ptr %count3, align 4
  %addtmp = add i32 %start.val18, %count.val19
  %n.val20 = load i32, ptr %n, align 4
  %cmptmp21 = icmp sgt i32 %addtmp, %n.val20
  %7 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %7, 0
  br i1 %ifcond22, label %then23, label %ifcont26

then23:                                           ; preds = %ifcont17
  %n.val24 = load i32, ptr %n, align 4
  %start.val25 = load i32, ptr %start2, align 4
  %subtmp = sub i32 %n.val24, %start.val25
  store i32 %subtmp, ptr %count3, align 4
  br label %ifcont26

ifcont26:                                         ; preds = %then23, %ifcont17
  %count.val27 = load i32, ptr %count3, align 4
  %addtmp28 = add i32 %count.val27, 1
  %call.arg.intcast = sext i32 %addtmp28 to i64
  %calltmp29 = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp29, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont26
  %i.val = load i32, ptr %i, align 4
  %count.val30 = load i32, ptr %count3, align 4
  %cmptmp31 = icmp slt i32 %i.val, %count.val30
  %8 = zext i1 %cmptmp31 to i32
  %forcond = icmp ne i32 %8, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %out.val = load ptr, ptr %out, align 8
  %i.val32 = load i32, ptr %i, align 4
  %string.index.addr.idx.i64 = sext i32 %i.val32 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 %string.index.addr.idx.i64
  %s.val33 = load ptr, ptr %s1, align 8
  %start.val34 = load i32, ptr %start2, align 4
  %i.val35 = load i32, ptr %i, align 4
  %addtmp36 = add i32 %start.val34, %i.val35
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp36 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %assign_trunc = trunc i32 %string.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %out.val37 = load ptr, ptr %out, align 8
  %runtime.move38 = call ptr @yc_move_to_parent(ptr %out.val37)
  call void @yc_frame_pop()
  ret ptr %runtime.move38
}

define i32 @std__text__count_char(ptr %s, i32 %ch) {
entry:
  %n = alloca i64, align 8
  %i = alloca i32, align 4
  %total = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %ch2 = alloca i32, align 4
  store i32 %ch, ptr %ch2, align 4
  call void @yc_frame_push()
  store i32 0, ptr %total, align 4
  store i32 0, ptr %i, align 4
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @std__str__len(ptr %s.val)
  store i64 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i64, ptr %n, align 4
  %0 = sext i32 %i.val to i64
  %cmptmp = icmp slt i64 %0, %n.val
  %1 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val3 = load ptr, ptr %s1, align 8
  %i.val4 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val4 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %ch.val = load i32, ptr %ch2, align 4
  %cmptmp5 = icmp eq i32 %string.index.i32, %ch.val
  %2 = zext i1 %cmptmp5 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %total.val = load i32, ptr %total, align 4
  call void @yc_frame_pop()
  ret i32 %total.val

then:                                             ; preds = %for.body
  %compound.current = load i32, ptr %total, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %total, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %for.body
  br label %for.inc
}

define i32 @std__text__line_of_offset(ptr %s, i32 %offset) {
entry:
  %i = alloca i32, align 4
  %line = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %offset2 = alloca i32, align 4
  store i32 %offset, ptr %offset2, align 4
  call void @yc_frame_push()
  store i32 0, ptr %line, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %offset.val = load i32, ptr %offset2, align 4
  %cmptmp = icmp slt i32 %i.val, %offset.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val = load ptr, ptr %s1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp4 = icmp eq i32 %string.index.i32, 10
  %1 = zext i1 %cmptmp4 to i32
  %ifcond = icmp ne i32 %1, 0
  br i1 %ifcond, label %then, label %ifcont

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %line.val = load i32, ptr %line, align 4
  call void @yc_frame_pop()
  ret i32 %line.val

then:                                             ; preds = %for.body
  %compound.current = load i32, ptr %line, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %line, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %for.body
  br label %for.inc
}

define i32 @std__text__column_of_offset(ptr %s, i32 %offset) {
entry:
  %i = alloca i32, align 4
  %col = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %offset2 = alloca i32, align 4
  store i32 %offset, ptr %offset2, align 4
  call void @yc_frame_push()
  store i32 0, ptr %col, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %offset.val = load i32, ptr %offset2, align 4
  %cmptmp = icmp slt i32 %i.val, %offset.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %s.val = load ptr, ptr %s1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp4 = icmp eq i32 %string.index.i32, 10
  %1 = zext i1 %cmptmp4 to i32
  %ifcond = icmp ne i32 %1, 0
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %col.val = load i32, ptr %col, align 4
  call void @yc_frame_pop()
  ret i32 %col.val

then:                                             ; preds = %for.body
  store i32 0, ptr %col, align 4
  br label %ifcont

else:                                             ; preds = %for.body
  %compound.current = load i32, ptr %col, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %col, align 4
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  br label %for.inc
}

define i32 @std__text__utf16_col(ptr %s, i32 %offset) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  %offset2 = alloca i32, align 4
  store i32 %offset, ptr %offset2, align 4
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %offset.val = load i32, ptr %offset2, align 4
  %calltmp = call i32 @std__text__column_of_offset(ptr %s.val, i32 %offset.val)
  call void @yc_frame_pop()
  ret i32 %calltmp
}

define internal %StringBuilder @std__text__invalid_builder() {
entry:
  %StringBuilder.tmp = alloca %StringBuilder, align 8
  call void @yc_frame_push()
  %StringBuilder.field0.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 0
  store ptr null, ptr %StringBuilder.field0.addr, align 8
  %StringBuilder.field1.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 1
  store ptr null, ptr %StringBuilder.field1.addr, align 8
  %StringBuilder.field2.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 2
  store i32 0, ptr %StringBuilder.field2.addr, align 4
  %StringBuilder.field3.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 3
  store i32 0, ptr %StringBuilder.field3.addr, align 4
  %StringBuilder.field4.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 4
  store i1 false, ptr %StringBuilder.field4.addr, align 1
  %return.load_struct = load %StringBuilder, ptr %StringBuilder.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct
}

define internal %StringBuilder @std__text__ensure_builder_cap(%StringBuilder %b, i32 %needed) {
entry:
  %StringBuilder.tmp90 = alloca %StringBuilder, align 8
  %i = alloca i32, align 4
  %data67 = alloca ptr, align 8
  %root62 = alloca ptr, align 8
  %StringBuilder.tmp48 = alloca %StringBuilder, align 8
  %root35 = alloca ptr, align 8
  %data31 = alloca ptr, align 8
  %StringBuilder.tmp = alloca %StringBuilder, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %next = alloca i32, align 4
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  %needed2 = alloca i32, align 4
  store i32 %needed, ptr %needed2, align 4
  call void @yc_frame_push()
  %needed.val = load i32, ptr %needed2, align 4
  %cap.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 3
  %cap.val = load i32, ptr %cap.addr, align 4
  %cmptmp = icmp sle i32 %needed.val, %cap.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %b.val = load %StringBuilder, ptr %b1, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %b.val

ifcont:                                           ; preds = %entry
  %cap.addr3 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 3
  %cap.val4 = load i32, ptr %cap.addr3, align 4
  store i32 %cap.val4, ptr %next, align 4
  %next.val = load i32, ptr %next, align 4
  %cmptmp5 = icmp slt i32 %next.val, 1
  %1 = zext i1 %cmptmp5 to i32
  %ifcond6 = icmp ne i32 %1, 0
  br i1 %ifcond6, label %then7, label %ifcont8

then7:                                            ; preds = %ifcont
  store i32 1, ptr %next, align 4
  br label %ifcont8

ifcont8:                                          ; preds = %then7, %ifcont
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont8
  %next.val9 = load i32, ptr %next, align 4
  %needed.val10 = load i32, ptr %needed2, align 4
  %cmptmp11 = icmp slt i32 %next.val9, %needed.val10
  %2 = zext i1 %cmptmp11 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %next.val12 = load i32, ptr %next, align 4
  %multmp = mul i32 %next.val12, 2
  store i32 %multmp, ptr %next, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %data.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp13 = icmp eq ptr %data.val, null
  %3 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %3, 0
  br i1 %ifcond14, label %then15, label %ifcont22

then15:                                           ; preds = %for.after
  %calltmp = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp, ptr %root, align 8
  %next.val16 = load i32, ptr %next, align 4
  %addtmp = add i32 %next.val16, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp17 = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp17, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val18 = load ptr, ptr %data, align 8
  call void @std__mem__attach_child(ptr %root.val, ptr %data.val18)
  %StringBuilder.field0.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 0
  %root.val19 = load ptr, ptr %root, align 8
  store ptr %root.val19, ptr %StringBuilder.field0.addr, align 8
  %StringBuilder.field1.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 1
  %data.val20 = load ptr, ptr %data, align 8
  store ptr %data.val20, ptr %StringBuilder.field1.addr, align 8
  %StringBuilder.field2.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 2
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  store i32 %len.val, ptr %StringBuilder.field2.addr, align 4
  %StringBuilder.field3.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 3
  %next.val21 = load i32, ptr %next, align 4
  store i32 %next.val21, ptr %StringBuilder.field3.addr, align 4
  %StringBuilder.field4.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr, align 1
  %return.load_struct = load %StringBuilder, ptr %StringBuilder.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct

ifcont22:                                         ; preds = %for.after
  %owns.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond23 = icmp ne i1 %owns.val, false
  br i1 %ifcond23, label %then24, label %ifcont60

then24:                                           ; preds = %ifcont22
  %data.addr25 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val26 = load ptr, ptr %data.addr25, align 8
  %next.val27 = load i32, ptr %next, align 4
  %addtmp28 = add i32 %next.val27, 1
  %call.arg.intcast29 = sext i32 %addtmp28 to i64
  %calltmp30 = call ptr @std__mem__realloc(ptr %data.val26, i64 %call.arg.intcast29)
  store ptr %calltmp30, ptr %data31, align 8
  %data.val32 = load ptr, ptr %data31, align 8
  %next.val33 = load i32, ptr %next, align 4
  %string.index.addr.idx.i64 = sext i32 %next.val33 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %data.val32, i64 %string.index.addr.idx.i64
  store i8 0, ptr %string.index.addr, align 1
  %root.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 0
  %root.val34 = load ptr, ptr %root.addr, align 8
  store ptr %root.val34, ptr %root35, align 8
  %root.val36 = load ptr, ptr %root35, align 8
  %cmptmp37 = icmp eq ptr %root.val36, null
  %4 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %4, 0
  br i1 %ifcond38, label %then39, label %else

then39:                                           ; preds = %then24
  %calltmp40 = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp40, ptr %root35, align 8
  %root.val41 = load ptr, ptr %root35, align 8
  %data.val42 = load ptr, ptr %data31, align 8
  call void @std__mem__attach_child(ptr %root.val41, ptr %data.val42)
  br label %ifcont47

else:                                             ; preds = %then24
  %root.val43 = load ptr, ptr %root35, align 8
  %data.addr44 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val45 = load ptr, ptr %data.addr44, align 8
  %data.val46 = load ptr, ptr %data31, align 8
  call void @std__mem__replace_child(ptr %root.val43, ptr %data.val45, ptr %data.val46)
  br label %ifcont47

ifcont47:                                         ; preds = %else, %then39
  %StringBuilder.field0.addr49 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 0
  %root.val50 = load ptr, ptr %root35, align 8
  store ptr %root.val50, ptr %StringBuilder.field0.addr49, align 8
  %StringBuilder.field1.addr51 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 1
  %data.val52 = load ptr, ptr %data31, align 8
  store ptr %data.val52, ptr %StringBuilder.field1.addr51, align 8
  %StringBuilder.field2.addr53 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 2
  %len.addr54 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val55 = load i32, ptr %len.addr54, align 4
  store i32 %len.val55, ptr %StringBuilder.field2.addr53, align 4
  %StringBuilder.field3.addr56 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 3
  %next.val57 = load i32, ptr %next, align 4
  store i32 %next.val57, ptr %StringBuilder.field3.addr56, align 4
  %StringBuilder.field4.addr58 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp48, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr58, align 1
  %return.load_struct59 = load %StringBuilder, ptr %StringBuilder.tmp48, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct59

ifcont60:                                         ; preds = %ifcont22
  %calltmp61 = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp61, ptr %root62, align 8
  %next.val63 = load i32, ptr %next, align 4
  %addtmp64 = add i32 %next.val63, 1
  %call.arg.intcast65 = sext i32 %addtmp64 to i64
  %calltmp66 = call ptr @std__mem__calloc(i64 %call.arg.intcast65, i64 1)
  store ptr %calltmp66, ptr %data67, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond68

for.cond68:                                       ; preds = %for.inc70, %ifcont60
  %i.val = load i32, ptr %i, align 4
  %len.addr72 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val73 = load i32, ptr %len.addr72, align 4
  %cmptmp74 = icmp slt i32 %i.val, %len.val73
  %5 = zext i1 %cmptmp74 to i32
  %forcond75 = icmp ne i32 %5, 0
  br i1 %forcond75, label %for.body69, label %for.after71

for.body69:                                       ; preds = %for.cond68
  %data.val76 = load ptr, ptr %data67, align 8
  %i.val77 = load i32, ptr %i, align 4
  %string.index.addr.idx.i6478 = sext i32 %i.val77 to i64
  %string.index.addr79 = getelementptr inbounds i8, ptr %data.val76, i64 %string.index.addr.idx.i6478
  %data.addr80 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val81 = load ptr, ptr %data.addr80, align 8
  %i.val82 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val82 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val81, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr79, align 1
  br label %for.inc70

for.inc70:                                        ; preds = %for.body69
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond68

for.after71:                                      ; preds = %for.cond68
  %data.val83 = load ptr, ptr %data67, align 8
  %len.addr84 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val85 = load i32, ptr %len.addr84, align 4
  %string.index.addr.idx.i6486 = sext i32 %len.val85 to i64
  %string.index.addr87 = getelementptr inbounds i8, ptr %data.val83, i64 %string.index.addr.idx.i6486
  store i8 0, ptr %string.index.addr87, align 1
  %root.val88 = load ptr, ptr %root62, align 8
  %data.val89 = load ptr, ptr %data67, align 8
  call void @std__mem__attach_child(ptr %root.val88, ptr %data.val89)
  %StringBuilder.field0.addr91 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 0
  %root.val92 = load ptr, ptr %root62, align 8
  store ptr %root.val92, ptr %StringBuilder.field0.addr91, align 8
  %StringBuilder.field1.addr93 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 1
  %data.val94 = load ptr, ptr %data67, align 8
  store ptr %data.val94, ptr %StringBuilder.field1.addr93, align 8
  %StringBuilder.field2.addr95 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 2
  %len.addr96 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val97 = load i32, ptr %len.addr96, align 4
  store i32 %len.val97, ptr %StringBuilder.field2.addr95, align 4
  %StringBuilder.field3.addr98 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 3
  %next.val99 = load i32, ptr %next, align 4
  store i32 %next.val99, ptr %StringBuilder.field3.addr98, align 4
  %StringBuilder.field4.addr100 = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp90, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr100, align 1
  %return.load_struct101 = load %StringBuilder, ptr %StringBuilder.tmp90, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct101
}

define %StringBuilder @std__text__new_builder(i32 %cap) {
entry:
  %StringBuilder.tmp = alloca %StringBuilder, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %cap1 = alloca i32, align 4
  store i32 %cap, ptr %cap1, align 4
  call void @yc_frame_push()
  %cap.val = load i32, ptr %cap1, align 4
  %cmptmp = icmp slt i32 %cap.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp = call %StringBuilder @std__text__invalid_builder()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %calltmp

ifcont:                                           ; preds = %entry
  %calltmp2 = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp2, ptr %root, align 8
  %cap.val3 = load i32, ptr %cap1, align 4
  %addtmp = add i32 %cap.val3, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp4 = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp4, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val = load ptr, ptr %data, align 8
  call void @std__mem__attach_child(ptr %root.val, ptr %data.val)
  %StringBuilder.field0.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 0
  %root.val5 = load ptr, ptr %root, align 8
  store ptr %root.val5, ptr %StringBuilder.field0.addr, align 8
  %StringBuilder.field1.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 1
  %data.val6 = load ptr, ptr %data, align 8
  store ptr %data.val6, ptr %StringBuilder.field1.addr, align 8
  %StringBuilder.field2.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 2
  store i32 0, ptr %StringBuilder.field2.addr, align 4
  %StringBuilder.field3.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 3
  %cap.val7 = load i32, ptr %cap1, align 4
  store i32 %cap.val7, ptr %StringBuilder.field3.addr, align 4
  %StringBuilder.field4.addr = getelementptr inbounds %StringBuilder, ptr %StringBuilder.tmp, i32 0, i32 4
  store i1 true, ptr %StringBuilder.field4.addr, align 1
  %return.load_struct = load %StringBuilder, ptr %StringBuilder.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %return.load_struct
}

define i32 @std__text__builder_len(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  call void @yc_frame_pop()
  ret i32 %len.val
}

define i32 @std__text__builder_cap(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %cap.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 3
  %cap.val = load i32, ptr %cap.addr, align 4
  call void @yc_frame_pop()
  ret i32 %cap.val
}

define %StringBuilder @std__text__append(%StringBuilder %b, ptr %src) {
entry:
  %out = alloca %StringBuilder, align 8
  %n = alloca i64, align 8
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  %src2 = alloca ptr, align 8
  store ptr %src, ptr %src2, align 8
  call void @yc_frame_push()
  %src.val = load ptr, ptr %src2, align 8
  %calltmp = call i64 @std__str__len(ptr %src.val)
  store i64 %calltmp, ptr %n, align 4
  %b.val = load %StringBuilder, ptr %b1, align 8
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %n.val = load i64, ptr %n, align 4
  %0 = sext i32 %len.val to i64
  %addtmp = add i64 %0, %n.val
  %call.arg.intcast = trunc i64 %addtmp to i32
  %calltmp3 = call %StringBuilder @std__text__ensure_builder_cap(%StringBuilder %b.val, i32 %call.arg.intcast)
  store %StringBuilder %calltmp3, ptr %out, align 8
  %data.addr = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %len.addr4 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val5 = load i32, ptr %len.addr4, align 4
  %ptraddtmp = getelementptr i8, ptr %data.val, i32 %len.val5
  %src.val6 = load ptr, ptr %src2, align 8
  %n.val7 = load i64, ptr %n, align 4
  %calltmp8 = call ptr @memcpy(ptr %ptraddtmp, ptr %src.val6, i64 %n.val7)
  %len.addr9 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %n.val10 = load i64, ptr %n, align 4
  %cast_int_field = trunc i64 %n.val10 to i32
  %compound.member.current = load i32, ptr %len.addr9, align 4
  %compound.add = add i32 %compound.member.current, %cast_int_field
  store i32 %compound.add, ptr %len.addr9, align 4
  %data.addr11 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val12 = load ptr, ptr %data.addr11, align 8
  %len.addr13 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val14 = load i32, ptr %len.addr13, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %len.val14 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val12, i64 %string.expr.index.addr.idx.i64
  store i8 0, ptr %string.expr.index.addr, align 1
  %out.val = load %StringBuilder, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %out.val
}

define %StringBuilder @std__text__append_char(%StringBuilder %b, i32 %ch) {
entry:
  %out = alloca %StringBuilder, align 8
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  %ch2 = alloca i32, align 4
  store i32 %ch, ptr %ch2, align 4
  call void @yc_frame_push()
  %b.val = load %StringBuilder, ptr %b1, align 8
  %len.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %addtmp = add i32 %len.val, 1
  %calltmp = call %StringBuilder @std__text__ensure_builder_cap(%StringBuilder %b.val, i32 %addtmp)
  store %StringBuilder %calltmp, ptr %out, align 8
  %data.addr = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %len.addr3 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %len.val4 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val, i64 %string.expr.index.addr.idx.i64
  %ch.val = load i32, ptr %ch2, align 4
  %assign_trunc = trunc i32 %ch.val to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  %len.addr5 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %compound.member.current = load i32, ptr %len.addr5, align 4
  %compound.add = add i32 %compound.member.current, 1
  store i32 %compound.add, ptr %len.addr5, align 4
  %data.addr6 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %len.addr8 = getelementptr inbounds %StringBuilder, ptr %out, i32 0, i32 2
  %len.val9 = load i32, ptr %len.addr8, align 4
  %string.expr.index.addr.idx.i6410 = sext i32 %len.val9 to i64
  %string.expr.index.addr11 = getelementptr inbounds i8, ptr %data.val7, i64 %string.expr.index.addr.idx.i6410
  store i8 0, ptr %string.expr.index.addr11, align 1
  %out.val = load %StringBuilder, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %StringBuilder %out.val
}

define ptr @std__text__to_string(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %runtime.move = call ptr @yc_move_to_parent(ptr %data.val)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std__text__free_builder(%StringBuilder %b) {
entry:
  %b1 = alloca %StringBuilder, align 8
  store %StringBuilder %b, ptr %b1, align 8
  call void @yc_frame_push()
  %owns.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond = icmp ne i1 %owns.val, false
  br i1 %ifcond, label %then, label %ifcont12

then:                                             ; preds = %entry
  %root.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 0
  %root.val = load ptr, ptr %root.addr, align 8
  %cmptmp = icmp ne ptr %root.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond2 = icmp ne i32 %0, 0
  br i1 %ifcond2, label %then3, label %else

then3:                                            ; preds = %then
  %root.addr4 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 0
  %root.val5 = load ptr, ptr %root.addr4, align 8
  call void @std__mem__free(ptr %root.val5)
  br label %ifcont11

else:                                             ; preds = %then
  %data.addr = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp6 = icmp ne ptr %data.val, null
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont

then8:                                            ; preds = %else
  %data.addr9 = getelementptr inbounds %StringBuilder, ptr %b1, i32 0, i32 1
  %data.val10 = load ptr, ptr %data.addr9, align 8
  call void @std__mem__free(ptr %data.val10)
  br label %ifcont

ifcont:                                           ; preds = %then8, %else
  br label %ifcont11

ifcont11:                                         ; preds = %ifcont, %then3
  br label %ifcont12

ifcont12:                                         ; preds = %ifcont11, %entry
  call void @yc_frame_pop()
  ret void
}

define ptr @std__text__builder_new(i32 %cap) {
entry:
  %data = alloca ptr, align 8
  %cap1 = alloca i32, align 4
  store i32 %cap, ptr %cap1, align 4
  call void @yc_frame_push()
  %cap.val = load i32, ptr %cap1, align 4
  %addtmp = add i32 %cap.val, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp, ptr %data, align 8
  %data.val = load ptr, ptr %data, align 8
  %runtime.move = call ptr @yc_move_to_parent(ptr %data.val)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define i32 @std__text__builder_append(ptr %dst, i32 %at, ptr %src) {
entry:
  %n = alloca i64, align 8
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %at2 = alloca i32, align 4
  store i32 %at, ptr %at2, align 4
  %src3 = alloca ptr, align 8
  store ptr %src, ptr %src3, align 8
  call void @yc_frame_push()
  %src.val = load ptr, ptr %src3, align 8
  %calltmp = call i64 @std__str__len(ptr %src.val)
  store i64 %calltmp, ptr %n, align 4
  %dst.val = load ptr, ptr %dst1, align 8
  %at.val = load i32, ptr %at2, align 4
  %ptraddtmp = getelementptr i8, ptr %dst.val, i32 %at.val
  %src.val4 = load ptr, ptr %src3, align 8
  %n.val = load i64, ptr %n, align 4
  %calltmp5 = call ptr @memcpy(ptr %ptraddtmp, ptr %src.val4, i64 %n.val)
  %at.val6 = load i32, ptr %at2, align 4
  %n.val7 = load i64, ptr %n, align 4
  %0 = sext i32 %at.val6 to i64
  %addtmp = add i64 %0, %n.val7
  %return.intcast = trunc i64 %addtmp to i32
  call void @yc_frame_pop()
  ret i32 %return.intcast
}

define void @std__text__builder_free(ptr %b) {
entry:
  %b1 = alloca ptr, align 8
  store ptr %b, ptr %b1, align 8
  call void @yc_frame_push()
  %b.val = load ptr, ptr %b1, align 8
  call void @std__mem__free(ptr %b.val)
  call void @yc_frame_pop()
  ret void
}

define %JsonValue @std__json__invalid_value(ptr %message) {
entry:
  %JsonValue.tmp = alloca %JsonValue, align 8
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  call void @yc_frame_push()
  %JsonValue.field0.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 0
  store i32 -1, ptr %JsonValue.field0.addr, align 4
  %JsonValue.field1.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 1
  store ptr null, ptr %JsonValue.field1.addr, align 8
  %JsonValue.field2.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 2
  store ptr null, ptr %JsonValue.field2.addr, align 8
  %JsonValue.field3.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 3
  store i32 0, ptr %JsonValue.field3.addr, align 4
  %JsonValue.field4.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 4
  store i32 0, ptr %JsonValue.field4.addr, align 4
  %JsonValue.field5.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 5
  store i1 false, ptr %JsonValue.field5.addr, align 1
  %JsonValue.field6.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 6
  %message.val = load ptr, ptr %message1, align 8
  store ptr %message.val, ptr %JsonValue.field6.addr, align 8
  %return.load_struct = load %JsonValue, ptr %JsonValue.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %return.load_struct
}

define i32 @std__json__skip_ws(ptr %message, i32 %i) {
entry:
  %n = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %i2 = alloca i32, align 4
  store i32 %i, ptr %i2, align 4
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %calltmp = call i32 @std__text__len(ptr %message.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i2, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i2, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val42 = load i32, ptr %i2, align 4
  call void @yc_frame_pop()
  ret i32 %i.val42

land.rhs:                                         ; preds = %for.cond
  %message.val7 = load ptr, ptr %message1, align 8
  %i.val8 = load i32, ptr %i2, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val8 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp9 = icmp eq i32 %string.index.i32, 32
  %1 = zext i1 %cmptmp9 to i32
  %lhsbool10 = icmp ne i32 %1, 0
  br i1 %lhsbool10, label %lor.end6, label %lor.rhs5

land.end:                                         ; preds = %lor.end, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool41, %lor.end ]
  %2 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

lor.rhs:                                          ; preds = %lor.end4
  %message.val31 = load ptr, ptr %message1, align 8
  %i.val32 = load i32, ptr %i2, align 4
  %string.local.ptr33 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6434 = sext i32 %i.val32 to i64
  %string.index.ptr35 = getelementptr inbounds i8, ptr %string.local.ptr33, i64 %string.index.ptr.idx.i6434
  %string.index.load36 = load i8, ptr %string.index.ptr35, align 1
  %string.index.i3237 = zext i8 %string.index.load36 to i32
  %cmptmp38 = icmp eq i32 %string.index.i3237, 9
  %3 = zext i1 %cmptmp38 to i32
  %rhsbool39 = icmp ne i32 %3, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end4
  %lortmp40 = phi i1 [ true, %lor.end4 ], [ %rhsbool39, %lor.rhs ]
  %4 = zext i1 %lortmp40 to i32
  %rhsbool41 = icmp ne i32 %4, 0
  br label %land.end

lor.rhs3:                                         ; preds = %lor.end6
  %message.val20 = load ptr, ptr %message1, align 8
  %i.val21 = load i32, ptr %i2, align 4
  %string.local.ptr22 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6423 = sext i32 %i.val21 to i64
  %string.index.ptr24 = getelementptr inbounds i8, ptr %string.local.ptr22, i64 %string.index.ptr.idx.i6423
  %string.index.load25 = load i8, ptr %string.index.ptr24, align 1
  %string.index.i3226 = zext i8 %string.index.load25 to i32
  %cmptmp27 = icmp eq i32 %string.index.i3226, 13
  %5 = zext i1 %cmptmp27 to i32
  %rhsbool28 = icmp ne i32 %5, 0
  br label %lor.end4

lor.end4:                                         ; preds = %lor.rhs3, %lor.end6
  %lortmp29 = phi i1 [ true, %lor.end6 ], [ %rhsbool28, %lor.rhs3 ]
  %6 = zext i1 %lortmp29 to i32
  %lhsbool30 = icmp ne i32 %6, 0
  br i1 %lhsbool30, label %lor.end, label %lor.rhs

lor.rhs5:                                         ; preds = %land.rhs
  %message.val11 = load ptr, ptr %message1, align 8
  %i.val12 = load i32, ptr %i2, align 4
  %string.local.ptr13 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6414 = sext i32 %i.val12 to i64
  %string.index.ptr15 = getelementptr inbounds i8, ptr %string.local.ptr13, i64 %string.index.ptr.idx.i6414
  %string.index.load16 = load i8, ptr %string.index.ptr15, align 1
  %string.index.i3217 = zext i8 %string.index.load16 to i32
  %cmptmp18 = icmp eq i32 %string.index.i3217, 10
  %7 = zext i1 %cmptmp18 to i32
  %rhsbool = icmp ne i32 %7, 0
  br label %lor.end6

lor.end6:                                         ; preds = %lor.rhs5, %land.rhs
  %lortmp = phi i1 [ true, %land.rhs ], [ %rhsbool, %lor.rhs5 ]
  %8 = zext i1 %lortmp to i32
  %lhsbool19 = icmp ne i32 %8, 0
  br i1 %lhsbool19, label %lor.end4, label %lor.rhs3
}

define internal i32 @std__json__string_end(ptr %source, i32 %start) {
entry:
  %ch = alloca i32, align 4
  %escape = alloca i1, align 1
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %start.val = load i32, ptr %start2, align 4
  %addtmp = add i32 %start.val, 1
  store i32 %addtmp, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  store i1 false, ptr %escape, align 1
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val3 = load ptr, ptr %source1, align 8
  %i.val4 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val4 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %escape.val = load i1, ptr %escape, align 1
  %ifcond = icmp ne i1 %escape.val, false
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont15
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

then:                                             ; preds = %for.body
  store i1 false, ptr %escape, align 1
  br label %ifcont15

else:                                             ; preds = %for.body
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp5 = icmp eq i32 %ch.val, 92
  %1 = zext i1 %cmptmp5 to i32
  %ifcond6 = icmp ne i32 %1, 0
  br i1 %ifcond6, label %then7, label %else8

then7:                                            ; preds = %else
  store i1 true, ptr %escape, align 1
  br label %ifcont14

else8:                                            ; preds = %else
  %ch.val9 = load i32, ptr %ch, align 4
  %cmptmp10 = icmp eq i32 %ch.val9, 34
  %2 = zext i1 %cmptmp10 to i32
  %ifcond11 = icmp ne i32 %2, 0
  br i1 %ifcond11, label %then12, label %ifcont

then12:                                           ; preds = %else8
  %i.val13 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val13

ifcont:                                           ; preds = %else8
  br label %ifcont14

ifcont14:                                         ; preds = %ifcont, %then7
  br label %ifcont15

ifcont15:                                         ; preds = %ifcont14, %then
  br label %for.inc
}

define internal i32 @std__json__matching_end(ptr %source, i32 %start, i32 %open_ch, i32 %close_ch) {
entry:
  %e = alloca i32, align 4
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %depth = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %open_ch3 = alloca i32, align 4
  store i32 %open_ch, ptr %open_ch3, align 4
  %close_ch4 = alloca i32, align 4
  store i32 %close_ch, ptr %close_ch4, align 4
  call void @yc_frame_push()
  store i32 0, ptr %depth, align 4
  %start.val = load i32, ptr %start2, align 4
  store i32 %start.val, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val5 = load ptr, ptr %source1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp7 = icmp eq i32 %ch.val, 34
  %1 = zext i1 %cmptmp7 to i32
  %ifcond = icmp ne i32 %1, 0
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont32
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

then:                                             ; preds = %for.body
  %source.val8 = load ptr, ptr %source1, align 8
  %i.val9 = load i32, ptr %i, align 4
  %calltmp10 = call i32 @std__json__string_end(ptr %source.val8, i32 %i.val9)
  store i32 %calltmp10, ptr %e, align 4
  %e.val = load i32, ptr %e, align 4
  %cmptmp11 = icmp slt i32 %e.val, 0
  %2 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %2, 0
  br i1 %ifcond12, label %then13, label %ifcont

then13:                                           ; preds = %then
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %then
  %e.val14 = load i32, ptr %e, align 4
  store i32 %e.val14, ptr %i, align 4
  br label %ifcont32

else:                                             ; preds = %for.body
  %ch.val15 = load i32, ptr %ch, align 4
  %open_ch.val = load i32, ptr %open_ch3, align 4
  %cmptmp16 = icmp eq i32 %ch.val15, %open_ch.val
  %3 = zext i1 %cmptmp16 to i32
  %ifcond17 = icmp ne i32 %3, 0
  br i1 %ifcond17, label %then18, label %else19

then18:                                           ; preds = %else
  %compound.current = load i32, ptr %depth, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %depth, align 4
  br label %ifcont31

else19:                                           ; preds = %else
  %ch.val20 = load i32, ptr %ch, align 4
  %close_ch.val = load i32, ptr %close_ch4, align 4
  %cmptmp21 = icmp eq i32 %ch.val20, %close_ch.val
  %4 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %4, 0
  br i1 %ifcond22, label %then23, label %ifcont30

then23:                                           ; preds = %else19
  %compound.current24 = load i32, ptr %depth, align 4
  %compound.sub = sub i32 %compound.current24, 1
  store i32 %compound.sub, ptr %depth, align 4
  %depth.val = load i32, ptr %depth, align 4
  %cmptmp25 = icmp eq i32 %depth.val, 0
  %5 = zext i1 %cmptmp25 to i32
  %ifcond26 = icmp ne i32 %5, 0
  br i1 %ifcond26, label %then27, label %ifcont29

then27:                                           ; preds = %then23
  %i.val28 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val28

ifcont29:                                         ; preds = %then23
  br label %ifcont30

ifcont30:                                         ; preds = %ifcont29, %else19
  br label %ifcont31

ifcont31:                                         ; preds = %ifcont30, %then18
  br label %ifcont32

ifcont32:                                         ; preds = %ifcont31, %ifcont
  br label %for.inc
}

define internal i32 @std__json__value_kind_at(ptr %source, i32 %start) {
entry:
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %i, align 4
  %source.val3 = load ptr, ptr %source1, align 8
  %calltmp4 = call i32 @std__text__len(ptr %source.val3)
  store i32 %calltmp4, ptr %n, align 4
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp sge i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val5 = load ptr, ptr %source1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp7 = icmp eq i32 %ch.val, 123
  %1 = zext i1 %cmptmp7 to i32
  %ifcond8 = icmp ne i32 %1, 0
  br i1 %ifcond8, label %then9, label %ifcont10

then9:                                            ; preds = %ifcont
  call void @yc_frame_pop()
  ret i32 1

ifcont10:                                         ; preds = %ifcont
  %ch.val11 = load i32, ptr %ch, align 4
  %cmptmp12 = icmp eq i32 %ch.val11, 91
  %2 = zext i1 %cmptmp12 to i32
  %ifcond13 = icmp ne i32 %2, 0
  br i1 %ifcond13, label %then14, label %ifcont15

then14:                                           ; preds = %ifcont10
  call void @yc_frame_pop()
  ret i32 2

ifcont15:                                         ; preds = %ifcont10
  %ch.val16 = load i32, ptr %ch, align 4
  %cmptmp17 = icmp eq i32 %ch.val16, 34
  %3 = zext i1 %cmptmp17 to i32
  %ifcond18 = icmp ne i32 %3, 0
  br i1 %ifcond18, label %then19, label %ifcont20

then19:                                           ; preds = %ifcont15
  call void @yc_frame_pop()
  ret i32 3

ifcont20:                                         ; preds = %ifcont15
  %ch.val21 = load i32, ptr %ch, align 4
  %cmptmp22 = icmp eq i32 %ch.val21, 116
  %4 = zext i1 %cmptmp22 to i32
  %lhsbool = icmp ne i32 %4, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont20
  %ch.val23 = load i32, ptr %ch, align 4
  %cmptmp24 = icmp eq i32 %ch.val23, 102
  %5 = zext i1 %cmptmp24 to i32
  %rhsbool = icmp ne i32 %5, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont20
  %lortmp = phi i1 [ true, %ifcont20 ], [ %rhsbool, %lor.rhs ]
  %6 = zext i1 %lortmp to i32
  %ifcond25 = icmp ne i32 %6, 0
  br i1 %ifcond25, label %then26, label %ifcont27

then26:                                           ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 4

ifcont27:                                         ; preds = %lor.end
  %ch.val28 = load i32, ptr %ch, align 4
  %cmptmp29 = icmp eq i32 %ch.val28, 110
  %7 = zext i1 %cmptmp29 to i32
  %ifcond30 = icmp ne i32 %7, 0
  br i1 %ifcond30, label %then31, label %ifcont32

then31:                                           ; preds = %ifcont27
  call void @yc_frame_pop()
  ret i32 5

ifcont32:                                         ; preds = %ifcont27
  %ch.val35 = load i32, ptr %ch, align 4
  %cmptmp36 = icmp eq i32 %ch.val35, 45
  %8 = zext i1 %cmptmp36 to i32
  %lhsbool37 = icmp ne i32 %8, 0
  br i1 %lhsbool37, label %lor.end34, label %lor.rhs33

lor.rhs33:                                        ; preds = %ifcont32
  %ch.val38 = load i32, ptr %ch, align 4
  %cmptmp39 = icmp sge i32 %ch.val38, 48
  %9 = zext i1 %cmptmp39 to i32
  %lhsbool40 = icmp ne i32 %9, 0
  br i1 %lhsbool40, label %land.rhs, label %land.end

lor.end34:                                        ; preds = %land.end, %ifcont32
  %lortmp45 = phi i1 [ true, %ifcont32 ], [ %rhsbool44, %land.end ]
  %10 = zext i1 %lortmp45 to i32
  %ifcond46 = icmp ne i32 %10, 0
  br i1 %ifcond46, label %then47, label %ifcont48

land.rhs:                                         ; preds = %lor.rhs33
  %ch.val41 = load i32, ptr %ch, align 4
  %cmptmp42 = icmp sle i32 %ch.val41, 57
  %11 = zext i1 %cmptmp42 to i32
  %rhsbool43 = icmp ne i32 %11, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %lor.rhs33
  %landtmp = phi i1 [ false, %lor.rhs33 ], [ %rhsbool43, %land.rhs ]
  %12 = zext i1 %landtmp to i32
  %rhsbool44 = icmp ne i32 %12, 0
  br label %lor.end34

then47:                                           ; preds = %lor.end34
  call void @yc_frame_pop()
  ret i32 6

ifcont48:                                         ; preds = %lor.end34
  call void @yc_frame_pop()
  ret i32 -1
}

define internal i32 @std__json__value_end(ptr %source, i32 %start) {
entry:
  %e42 = alloca i32, align 4
  %e26 = alloca i32, align 4
  %e = alloca i32, align 4
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %i, align 4
  %source.val3 = load ptr, ptr %source1, align 8
  %calltmp4 = call i32 @std__text__len(ptr %source.val3)
  store i32 %calltmp4, ptr %n, align 4
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp sge i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val5 = load ptr, ptr %source1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp7 = icmp eq i32 %ch.val, 34
  %1 = zext i1 %cmptmp7 to i32
  %ifcond8 = icmp ne i32 %1, 0
  br i1 %ifcond8, label %then9, label %ifcont18

then9:                                            ; preds = %ifcont
  %source.val10 = load ptr, ptr %source1, align 8
  %i.val11 = load i32, ptr %i, align 4
  %calltmp12 = call i32 @std__json__string_end(ptr %source.val10, i32 %i.val11)
  store i32 %calltmp12, ptr %e, align 4
  %e.val = load i32, ptr %e, align 4
  %cmptmp13 = icmp slt i32 %e.val, 0
  %2 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %2, 0
  br i1 %ifcond14, label %then15, label %ifcont16

then15:                                           ; preds = %then9
  call void @yc_frame_pop()
  ret i32 -1

ifcont16:                                         ; preds = %then9
  %e.val17 = load i32, ptr %e, align 4
  %addtmp = add i32 %e.val17, 1
  call void @yc_frame_pop()
  ret i32 %addtmp

ifcont18:                                         ; preds = %ifcont
  %ch.val19 = load i32, ptr %ch, align 4
  %cmptmp20 = icmp eq i32 %ch.val19, 123
  %3 = zext i1 %cmptmp20 to i32
  %ifcond21 = icmp ne i32 %3, 0
  br i1 %ifcond21, label %then22, label %ifcont34

then22:                                           ; preds = %ifcont18
  %source.val23 = load ptr, ptr %source1, align 8
  %i.val24 = load i32, ptr %i, align 4
  %calltmp25 = call i32 @std__json__matching_end(ptr %source.val23, i32 %i.val24, i32 123, i32 125)
  store i32 %calltmp25, ptr %e26, align 4
  %e.val27 = load i32, ptr %e26, align 4
  %cmptmp28 = icmp slt i32 %e.val27, 0
  %4 = zext i1 %cmptmp28 to i32
  %ifcond29 = icmp ne i32 %4, 0
  br i1 %ifcond29, label %then30, label %ifcont31

then30:                                           ; preds = %then22
  call void @yc_frame_pop()
  ret i32 -1

ifcont31:                                         ; preds = %then22
  %e.val32 = load i32, ptr %e26, align 4
  %addtmp33 = add i32 %e.val32, 1
  call void @yc_frame_pop()
  ret i32 %addtmp33

ifcont34:                                         ; preds = %ifcont18
  %ch.val35 = load i32, ptr %ch, align 4
  %cmptmp36 = icmp eq i32 %ch.val35, 91
  %5 = zext i1 %cmptmp36 to i32
  %ifcond37 = icmp ne i32 %5, 0
  br i1 %ifcond37, label %then38, label %ifcont50

then38:                                           ; preds = %ifcont34
  %source.val39 = load ptr, ptr %source1, align 8
  %i.val40 = load i32, ptr %i, align 4
  %calltmp41 = call i32 @std__json__matching_end(ptr %source.val39, i32 %i.val40, i32 91, i32 93)
  store i32 %calltmp41, ptr %e42, align 4
  %e.val43 = load i32, ptr %e42, align 4
  %cmptmp44 = icmp slt i32 %e.val43, 0
  %6 = zext i1 %cmptmp44 to i32
  %ifcond45 = icmp ne i32 %6, 0
  br i1 %ifcond45, label %then46, label %ifcont47

then46:                                           ; preds = %then38
  call void @yc_frame_pop()
  ret i32 -1

ifcont47:                                         ; preds = %then38
  %e.val48 = load i32, ptr %e42, align 4
  %addtmp49 = add i32 %e.val48, 1
  call void @yc_frame_pop()
  ret i32 %addtmp49

ifcont50:                                         ; preds = %ifcont34
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont50
  %i.val63 = load i32, ptr %i, align 4
  %n.val64 = load i32, ptr %n, align 4
  %cmptmp65 = icmp slt i32 %i.val63, %n.val64
  %7 = zext i1 %cmptmp65 to i32
  %lhsbool = icmp ne i32 %7, 0
  br i1 %lhsbool, label %land.rhs61, label %land.end62

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val140 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val140

land.rhs:                                         ; preds = %land.end52
  %source.val130 = load ptr, ptr %source1, align 8
  %i.val131 = load i32, ptr %i, align 4
  %string.local.ptr132 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64133 = sext i32 %i.val131 to i64
  %string.index.ptr134 = getelementptr inbounds i8, ptr %string.local.ptr132, i64 %string.index.ptr.idx.i64133
  %string.index.load135 = load i8, ptr %string.index.ptr134, align 1
  %string.index.i32136 = zext i8 %string.index.load135 to i32
  %cmptmp137 = icmp ne i32 %string.index.i32136, 32
  %8 = zext i1 %cmptmp137 to i32
  %rhsbool138 = icmp ne i32 %8, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.end52
  %landtmp139 = phi i1 [ false, %land.end52 ], [ %rhsbool138, %land.rhs ]
  %9 = zext i1 %landtmp139 to i32
  %forcond = icmp ne i32 %9, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs51:                                       ; preds = %land.end54
  %source.val119 = load ptr, ptr %source1, align 8
  %i.val120 = load i32, ptr %i, align 4
  %string.local.ptr121 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64122 = sext i32 %i.val120 to i64
  %string.index.ptr123 = getelementptr inbounds i8, ptr %string.local.ptr121, i64 %string.index.ptr.idx.i64122
  %string.index.load124 = load i8, ptr %string.index.ptr123, align 1
  %string.index.i32125 = zext i8 %string.index.load124 to i32
  %cmptmp126 = icmp ne i32 %string.index.i32125, 9
  %10 = zext i1 %cmptmp126 to i32
  %rhsbool127 = icmp ne i32 %10, 0
  br label %land.end52

land.end52:                                       ; preds = %land.rhs51, %land.end54
  %landtmp128 = phi i1 [ false, %land.end54 ], [ %rhsbool127, %land.rhs51 ]
  %11 = zext i1 %landtmp128 to i32
  %lhsbool129 = icmp ne i32 %11, 0
  br i1 %lhsbool129, label %land.rhs, label %land.end

land.rhs53:                                       ; preds = %land.end56
  %source.val108 = load ptr, ptr %source1, align 8
  %i.val109 = load i32, ptr %i, align 4
  %string.local.ptr110 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64111 = sext i32 %i.val109 to i64
  %string.index.ptr112 = getelementptr inbounds i8, ptr %string.local.ptr110, i64 %string.index.ptr.idx.i64111
  %string.index.load113 = load i8, ptr %string.index.ptr112, align 1
  %string.index.i32114 = zext i8 %string.index.load113 to i32
  %cmptmp115 = icmp ne i32 %string.index.i32114, 13
  %12 = zext i1 %cmptmp115 to i32
  %rhsbool116 = icmp ne i32 %12, 0
  br label %land.end54

land.end54:                                       ; preds = %land.rhs53, %land.end56
  %landtmp117 = phi i1 [ false, %land.end56 ], [ %rhsbool116, %land.rhs53 ]
  %13 = zext i1 %landtmp117 to i32
  %lhsbool118 = icmp ne i32 %13, 0
  br i1 %lhsbool118, label %land.rhs51, label %land.end52

land.rhs55:                                       ; preds = %land.end58
  %source.val97 = load ptr, ptr %source1, align 8
  %i.val98 = load i32, ptr %i, align 4
  %string.local.ptr99 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64100 = sext i32 %i.val98 to i64
  %string.index.ptr101 = getelementptr inbounds i8, ptr %string.local.ptr99, i64 %string.index.ptr.idx.i64100
  %string.index.load102 = load i8, ptr %string.index.ptr101, align 1
  %string.index.i32103 = zext i8 %string.index.load102 to i32
  %cmptmp104 = icmp ne i32 %string.index.i32103, 10
  %14 = zext i1 %cmptmp104 to i32
  %rhsbool105 = icmp ne i32 %14, 0
  br label %land.end56

land.end56:                                       ; preds = %land.rhs55, %land.end58
  %landtmp106 = phi i1 [ false, %land.end58 ], [ %rhsbool105, %land.rhs55 ]
  %15 = zext i1 %landtmp106 to i32
  %lhsbool107 = icmp ne i32 %15, 0
  br i1 %lhsbool107, label %land.rhs53, label %land.end54

land.rhs57:                                       ; preds = %land.end60
  %source.val86 = load ptr, ptr %source1, align 8
  %i.val87 = load i32, ptr %i, align 4
  %string.local.ptr88 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6489 = sext i32 %i.val87 to i64
  %string.index.ptr90 = getelementptr inbounds i8, ptr %string.local.ptr88, i64 %string.index.ptr.idx.i6489
  %string.index.load91 = load i8, ptr %string.index.ptr90, align 1
  %string.index.i3292 = zext i8 %string.index.load91 to i32
  %cmptmp93 = icmp ne i32 %string.index.i3292, 93
  %16 = zext i1 %cmptmp93 to i32
  %rhsbool94 = icmp ne i32 %16, 0
  br label %land.end58

land.end58:                                       ; preds = %land.rhs57, %land.end60
  %landtmp95 = phi i1 [ false, %land.end60 ], [ %rhsbool94, %land.rhs57 ]
  %17 = zext i1 %landtmp95 to i32
  %lhsbool96 = icmp ne i32 %17, 0
  br i1 %lhsbool96, label %land.rhs55, label %land.end56

land.rhs59:                                       ; preds = %land.end62
  %source.val75 = load ptr, ptr %source1, align 8
  %i.val76 = load i32, ptr %i, align 4
  %string.local.ptr77 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6478 = sext i32 %i.val76 to i64
  %string.index.ptr79 = getelementptr inbounds i8, ptr %string.local.ptr77, i64 %string.index.ptr.idx.i6478
  %string.index.load80 = load i8, ptr %string.index.ptr79, align 1
  %string.index.i3281 = zext i8 %string.index.load80 to i32
  %cmptmp82 = icmp ne i32 %string.index.i3281, 125
  %18 = zext i1 %cmptmp82 to i32
  %rhsbool83 = icmp ne i32 %18, 0
  br label %land.end60

land.end60:                                       ; preds = %land.rhs59, %land.end62
  %landtmp84 = phi i1 [ false, %land.end62 ], [ %rhsbool83, %land.rhs59 ]
  %19 = zext i1 %landtmp84 to i32
  %lhsbool85 = icmp ne i32 %19, 0
  br i1 %lhsbool85, label %land.rhs57, label %land.end58

land.rhs61:                                       ; preds = %for.cond
  %source.val66 = load ptr, ptr %source1, align 8
  %i.val67 = load i32, ptr %i, align 4
  %string.local.ptr68 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6469 = sext i32 %i.val67 to i64
  %string.index.ptr70 = getelementptr inbounds i8, ptr %string.local.ptr68, i64 %string.index.ptr.idx.i6469
  %string.index.load71 = load i8, ptr %string.index.ptr70, align 1
  %string.index.i3272 = zext i8 %string.index.load71 to i32
  %cmptmp73 = icmp ne i32 %string.index.i3272, 44
  %20 = zext i1 %cmptmp73 to i32
  %rhsbool = icmp ne i32 %20, 0
  br label %land.end62

land.end62:                                       ; preds = %land.rhs61, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs61 ]
  %21 = zext i1 %landtmp to i32
  %lhsbool74 = icmp ne i32 %21, 0
  br i1 %lhsbool74, label %land.rhs59, label %land.end60
}

define internal %JsonValue @std__json__make_view(ptr %source, ptr %root, i32 %start, i32 %end_pos, i1 %should_own) {
entry:
  %JsonValue.tmp = alloca %JsonValue, align 8
  %k = alloca i32, align 4
  %real_start = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %root2 = alloca ptr, align 8
  store ptr %root, ptr %root2, align 8
  %start3 = alloca i32, align 4
  store i32 %start, ptr %start3, align 4
  %end_pos4 = alloca i32, align 4
  store i32 %end_pos, ptr %end_pos4, align 4
  %should_own5 = alloca i1, align 1
  store i1 %should_own, ptr %should_own5, align 1
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start3, align 4
  %calltmp = call i32 @std__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %real_start, align 4
  %source.val6 = load ptr, ptr %source1, align 8
  %real_start.val = load i32, ptr %real_start, align 4
  %calltmp7 = call i32 @std__json__value_kind_at(ptr %source.val6, i32 %real_start.val)
  store i32 %calltmp7, ptr %k, align 4
  %k.val = load i32, ptr %k, align 4
  %cmptmp = icmp slt i32 %k.val, 0
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %end_pos.val = load i32, ptr %end_pos4, align 4
  %real_start.val8 = load i32, ptr %real_start, align 4
  %cmptmp9 = icmp slt i32 %end_pos.val, %real_start.val8
  %1 = zext i1 %cmptmp9 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %calltmp10 = call %JsonValue @std__json__invalid_value(ptr @.str.50)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp10

ifcont:                                           ; preds = %lor.end
  %JsonValue.field0.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 0
  %k.val11 = load i32, ptr %k, align 4
  store i32 %k.val11, ptr %JsonValue.field0.addr, align 4
  %JsonValue.field1.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 1
  %root.val = load ptr, ptr %root2, align 8
  store ptr %root.val, ptr %JsonValue.field1.addr, align 8
  %JsonValue.field2.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 2
  %source.val12 = load ptr, ptr %source1, align 8
  store ptr %source.val12, ptr %JsonValue.field2.addr, align 8
  %JsonValue.field3.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 3
  %real_start.val13 = load i32, ptr %real_start, align 4
  store i32 %real_start.val13, ptr %JsonValue.field3.addr, align 4
  %JsonValue.field4.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 4
  %end_pos.val14 = load i32, ptr %end_pos4, align 4
  store i32 %end_pos.val14, ptr %JsonValue.field4.addr, align 4
  %JsonValue.field5.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 5
  %should_own.val = load i1, ptr %should_own5, align 1
  store i1 %should_own.val, ptr %JsonValue.field5.addr, align 1
  %JsonValue.field6.addr = getelementptr inbounds %JsonValue, ptr %JsonValue.tmp, i32 0, i32 6
  store ptr @.str.51, ptr %JsonValue.field6.addr, align 8
  %return.load_struct = load %JsonValue, ptr %JsonValue.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %return.load_struct
}

define %JsonValue @std__json__parse(ptr %source) {
entry:
  %root = alloca ptr, align 8
  %trailing = alloca i32, align 4
  %end_pos = alloca i32, align 4
  %start = alloca i32, align 4
  %copy = alloca ptr, align 8
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %cmptmp = icmp eq ptr %source.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp = call %JsonValue @std__json__invalid_value(ptr @.str.52)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %calltmp3 = call i32 @std__text__len(ptr %source.val2)
  store i32 %calltmp3, ptr %n, align 4
  %source.val4 = load ptr, ptr %source1, align 8
  %n.val = load i32, ptr %n, align 4
  %calltmp5 = call ptr @std__text__slice(ptr %source.val4, i32 0, i32 %n.val)
  store ptr %calltmp5, ptr %copy, align 8
  %copy.val = load ptr, ptr %copy, align 8
  %calltmp6 = call i32 @std__json__skip_ws(ptr %copy.val, i32 0)
  store i32 %calltmp6, ptr %start, align 4
  %copy.val7 = load ptr, ptr %copy, align 8
  %start.val = load i32, ptr %start, align 4
  %calltmp8 = call i32 @std__json__value_end(ptr %copy.val7, i32 %start.val)
  store i32 %calltmp8, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp9 = icmp slt i32 %end_pos.val, 0
  %1 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %1, 0
  br i1 %ifcond10, label %then11, label %ifcont14

then11:                                           ; preds = %ifcont
  %copy.val12 = load ptr, ptr %copy, align 8
  call void @std__mem__free(ptr %copy.val12)
  %calltmp13 = call %JsonValue @std__json__invalid_value(ptr @.str.53)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp13

ifcont14:                                         ; preds = %ifcont
  %copy.val15 = load ptr, ptr %copy, align 8
  %end_pos.val16 = load i32, ptr %end_pos, align 4
  %calltmp17 = call i32 @std__json__skip_ws(ptr %copy.val15, i32 %end_pos.val16)
  store i32 %calltmp17, ptr %trailing, align 4
  %trailing.val = load i32, ptr %trailing, align 4
  %n.val18 = load i32, ptr %n, align 4
  %cmptmp19 = icmp ne i32 %trailing.val, %n.val18
  %2 = zext i1 %cmptmp19 to i32
  %ifcond20 = icmp ne i32 %2, 0
  br i1 %ifcond20, label %then21, label %ifcont24

then21:                                           ; preds = %ifcont14
  %copy.val22 = load ptr, ptr %copy, align 8
  call void @std__mem__free(ptr %copy.val22)
  %calltmp23 = call %JsonValue @std__json__invalid_value(ptr @.str.54)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp23

ifcont24:                                         ; preds = %ifcont14
  %calltmp25 = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp25, ptr %root, align 8
  %root.val = load ptr, ptr %root, align 8
  %copy.val26 = load ptr, ptr %copy, align 8
  call void @std__mem__attach_child(ptr %root.val, ptr %copy.val26)
  %copy.val27 = load ptr, ptr %copy, align 8
  %root.val28 = load ptr, ptr %root, align 8
  %start.val29 = load i32, ptr %start, align 4
  %end_pos.val30 = load i32, ptr %end_pos, align 4
  %calltmp31 = call %JsonValue @std__json__make_view(ptr %copy.val27, ptr %root.val28, i32 %start.val29, i32 %end_pos.val30, i1 true)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp31
}

define i32 @std__json__kind(%JsonValue %value) {
entry:
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  call void @yc_frame_pop()
  ret i32 %kind.val
}

define ptr @std__json__stringify(%JsonValue %value) {
entry:
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp slt i32 %kind.val, 0
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp2 = icmp eq ptr %source.val, null
  %1 = zext i1 %cmptmp2 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %runtime.move = call ptr @yc_move_to_parent(ptr @.str.55)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %lor.end
  %source.addr3 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val4 = load ptr, ptr %source.addr3, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %start.addr5 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val6 = load i32, ptr %start.addr5, align 4
  %subtmp = sub i32 %end.val, %start.val6
  %calltmp = call ptr @std__text__slice(ptr %source.val4, i32 %start.val, i32 %subtmp)
  %runtime.move7 = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move7
}

define internal i1 @std__json__key_eq(ptr %source, i32 %key_start, i32 %key_end, ptr %key) {
entry:
  %i = alloca i32, align 4
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %key_start2 = alloca i32, align 4
  store i32 %key_start, ptr %key_start2, align 4
  %key_end3 = alloca i32, align 4
  store i32 %key_end, ptr %key_end3, align 4
  %key4 = alloca ptr, align 8
  store ptr %key, ptr %key4, align 8
  call void @yc_frame_push()
  %key.val = load ptr, ptr %key4, align 8
  %calltmp = call i32 @std__text__len(ptr %key.val)
  store i32 %calltmp, ptr %n, align 4
  %key_end.val = load i32, ptr %key_end3, align 4
  %key_start.val = load i32, ptr %key_start2, align 4
  %subtmp = sub i32 %key_end.val, %key_start.val
  %subtmp5 = sub i32 %subtmp, 1
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp ne i32 %subtmp5, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val6 = load i32, ptr %n, align 4
  %cmptmp7 = icmp slt i32 %i.val, %n.val6
  %1 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val = load ptr, ptr %source1, align 8
  %key_start.val8 = load i32, ptr %key_start2, align 4
  %addtmp = add i32 %key_start.val8, 1
  %i.val9 = load i32, ptr %i, align 4
  %addtmp10 = add i32 %addtmp, %i.val9
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp10 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %key.val11 = load ptr, ptr %key4, align 8
  %i.val12 = load i32, ptr %i, align 4
  %string.local.ptr13 = load ptr, ptr %key4, align 8
  %string.index.ptr.idx.i6414 = sext i32 %i.val12 to i64
  %string.index.ptr15 = getelementptr inbounds i8, ptr %string.local.ptr13, i64 %string.index.ptr.idx.i6414
  %string.index.load16 = load i8, ptr %string.index.ptr15, align 1
  %string.index.i3217 = zext i8 %string.index.load16 to i32
  %cmptmp18 = icmp ne i32 %string.index.i32, %string.index.i3217
  %2 = zext i1 %cmptmp18 to i32
  %ifcond19 = icmp ne i32 %2, 0
  br i1 %ifcond19, label %then20, label %ifcont21

for.inc:                                          ; preds = %ifcont21
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then20:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont21:                                         ; preds = %for.body
  br label %for.inc
}

define internal i32 @std__json__object_value_start(%JsonValue %obj, ptr %key) {
entry:
  %value_stop = alloca i32, align 4
  %value_start = alloca i32, align 4
  %after_key = alloca i32, align 4
  %key_end = alloca i32, align 4
  %i = alloca i32, align 4
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 1
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp3 = icmp eq ptr %source.val, null
  %1 = zext i1 %cmptmp3 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %lor.end
  %source.addr4 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val5 = load ptr, ptr %source.addr4, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %addtmp = add i32 %start.val, 1
  %calltmp = call i32 @std__json__skip_ws(ptr %source.val5, i32 %addtmp)
  store i32 %calltmp, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %cmptmp6 = icmp slt i32 %i.val, %end.val
  %3 = zext i1 %cmptmp6 to i32
  %forcond = icmp ne i32 %3, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.addr7 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val8 = load ptr, ptr %source.addr7, align 8
  %i.val9 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val9 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val8, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp10 = icmp eq i32 %string.expr.index.i32, 125
  %4 = zext i1 %cmptmp10 to i32
  %ifcond11 = icmp ne i32 %4, 0
  br i1 %ifcond11, label %then12, label %ifcont13

for.inc:                                          ; preds = %ifcont103
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

then12:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i32 -1

ifcont13:                                         ; preds = %for.body
  %source.addr14 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val15 = load ptr, ptr %source.addr14, align 8
  %i.val16 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6417 = sext i32 %i.val16 to i64
  %string.expr.index.ptr18 = getelementptr inbounds i8, ptr %source.val15, i64 %string.expr.index.ptr.idx.i6417
  %string.expr.index.load19 = load i8, ptr %string.expr.index.ptr18, align 1
  %string.expr.index.i3220 = zext i8 %string.expr.index.load19 to i32
  %cmptmp21 = icmp ne i32 %string.expr.index.i3220, 34
  %5 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %5, 0
  br i1 %ifcond22, label %then23, label %ifcont24

then23:                                           ; preds = %ifcont13
  call void @yc_frame_pop()
  ret i32 -1

ifcont24:                                         ; preds = %ifcont13
  %source.addr25 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val26 = load ptr, ptr %source.addr25, align 8
  %i.val27 = load i32, ptr %i, align 4
  %calltmp28 = call i32 @std__json__string_end(ptr %source.val26, i32 %i.val27)
  store i32 %calltmp28, ptr %key_end, align 4
  %key_end.val = load i32, ptr %key_end, align 4
  %cmptmp29 = icmp slt i32 %key_end.val, 0
  %6 = zext i1 %cmptmp29 to i32
  %ifcond30 = icmp ne i32 %6, 0
  br i1 %ifcond30, label %then31, label %ifcont32

then31:                                           ; preds = %ifcont24
  call void @yc_frame_pop()
  ret i32 -1

ifcont32:                                         ; preds = %ifcont24
  %source.addr33 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val34 = load ptr, ptr %source.addr33, align 8
  %key_end.val35 = load i32, ptr %key_end, align 4
  %addtmp36 = add i32 %key_end.val35, 1
  %calltmp37 = call i32 @std__json__skip_ws(ptr %source.val34, i32 %addtmp36)
  store i32 %calltmp37, ptr %after_key, align 4
  %after_key.val = load i32, ptr %after_key, align 4
  %end.addr40 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 4
  %end.val41 = load i32, ptr %end.addr40, align 4
  %cmptmp42 = icmp sge i32 %after_key.val, %end.val41
  %7 = zext i1 %cmptmp42 to i32
  %lhsbool43 = icmp ne i32 %7, 0
  br i1 %lhsbool43, label %lor.end39, label %lor.rhs38

lor.rhs38:                                        ; preds = %ifcont32
  %source.addr44 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val45 = load ptr, ptr %source.addr44, align 8
  %after_key.val46 = load i32, ptr %after_key, align 4
  %string.expr.index.ptr.idx.i6447 = sext i32 %after_key.val46 to i64
  %string.expr.index.ptr48 = getelementptr inbounds i8, ptr %source.val45, i64 %string.expr.index.ptr.idx.i6447
  %string.expr.index.load49 = load i8, ptr %string.expr.index.ptr48, align 1
  %string.expr.index.i3250 = zext i8 %string.expr.index.load49 to i32
  %cmptmp51 = icmp ne i32 %string.expr.index.i3250, 58
  %8 = zext i1 %cmptmp51 to i32
  %rhsbool52 = icmp ne i32 %8, 0
  br label %lor.end39

lor.end39:                                        ; preds = %lor.rhs38, %ifcont32
  %lortmp53 = phi i1 [ true, %ifcont32 ], [ %rhsbool52, %lor.rhs38 ]
  %9 = zext i1 %lortmp53 to i32
  %ifcond54 = icmp ne i32 %9, 0
  br i1 %ifcond54, label %then55, label %ifcont56

then55:                                           ; preds = %lor.end39
  call void @yc_frame_pop()
  ret i32 -1

ifcont56:                                         ; preds = %lor.end39
  %source.addr57 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val58 = load ptr, ptr %source.addr57, align 8
  %after_key.val59 = load i32, ptr %after_key, align 4
  %addtmp60 = add i32 %after_key.val59, 1
  %calltmp61 = call i32 @std__json__skip_ws(ptr %source.val58, i32 %addtmp60)
  store i32 %calltmp61, ptr %value_start, align 4
  %source.addr62 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val63 = load ptr, ptr %source.addr62, align 8
  %value_start.val = load i32, ptr %value_start, align 4
  %calltmp64 = call i32 @std__json__value_end(ptr %source.val63, i32 %value_start.val)
  store i32 %calltmp64, ptr %value_stop, align 4
  %value_stop.val = load i32, ptr %value_stop, align 4
  %cmptmp65 = icmp slt i32 %value_stop.val, 0
  %10 = zext i1 %cmptmp65 to i32
  %ifcond66 = icmp ne i32 %10, 0
  br i1 %ifcond66, label %then67, label %ifcont68

then67:                                           ; preds = %ifcont56
  call void @yc_frame_pop()
  ret i32 -1

ifcont68:                                         ; preds = %ifcont56
  %source.addr69 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val70 = load ptr, ptr %source.addr69, align 8
  %i.val71 = load i32, ptr %i, align 4
  %key_end.val72 = load i32, ptr %key_end, align 4
  %key.val = load ptr, ptr %key2, align 8
  %calltmp73 = call i1 @std__json__key_eq(ptr %source.val70, i32 %i.val71, i32 %key_end.val72, ptr %key.val)
  %ifcond74 = icmp ne i1 %calltmp73, false
  br i1 %ifcond74, label %then75, label %ifcont77

then75:                                           ; preds = %ifcont68
  %value_start.val76 = load i32, ptr %value_start, align 4
  call void @yc_frame_pop()
  ret i32 %value_start.val76

ifcont77:                                         ; preds = %ifcont68
  %source.addr78 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val79 = load ptr, ptr %source.addr78, align 8
  %value_stop.val80 = load i32, ptr %value_stop, align 4
  %calltmp81 = call i32 @std__json__skip_ws(ptr %source.val79, i32 %value_stop.val80)
  store i32 %calltmp81, ptr %i, align 4
  %i.val82 = load i32, ptr %i, align 4
  %end.addr83 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 4
  %end.val84 = load i32, ptr %end.addr83, align 4
  %cmptmp85 = icmp slt i32 %i.val82, %end.val84
  %11 = zext i1 %cmptmp85 to i32
  %lhsbool86 = icmp ne i32 %11, 0
  br i1 %lhsbool86, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont77
  %source.addr87 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val88 = load ptr, ptr %source.addr87, align 8
  %i.val89 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6490 = sext i32 %i.val89 to i64
  %string.expr.index.ptr91 = getelementptr inbounds i8, ptr %source.val88, i64 %string.expr.index.ptr.idx.i6490
  %string.expr.index.load92 = load i8, ptr %string.expr.index.ptr91, align 1
  %string.expr.index.i3293 = zext i8 %string.expr.index.load92 to i32
  %cmptmp94 = icmp eq i32 %string.expr.index.i3293, 44
  %12 = zext i1 %cmptmp94 to i32
  %rhsbool95 = icmp ne i32 %12, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont77
  %landtmp = phi i1 [ false, %ifcont77 ], [ %rhsbool95, %land.rhs ]
  %13 = zext i1 %landtmp to i32
  %ifcond96 = icmp ne i32 %13, 0
  br i1 %ifcond96, label %then97, label %ifcont103

then97:                                           ; preds = %land.end
  %source.addr98 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val99 = load ptr, ptr %source.addr98, align 8
  %i.val100 = load i32, ptr %i, align 4
  %addtmp101 = add i32 %i.val100, 1
  %calltmp102 = call i32 @std__json__skip_ws(ptr %source.val99, i32 %addtmp101)
  store i32 %calltmp102, ptr %i, align 4
  br label %ifcont103

ifcont103:                                        ; preds = %then97, %land.end
  br label %for.inc
}

define %JsonValue @std__json__get(%JsonValue %obj, ptr %key) {
entry:
  %end_pos = alloca i32, align 4
  %start = alloca i32, align 4
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std__json__object_value_start(%JsonValue %obj.val, ptr %key.val)
  store i32 %calltmp, ptr %start, align 4
  %start.val = load i32, ptr %start, align 4
  %cmptmp = icmp slt i32 %start.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp3 = call %JsonValue @std__json__invalid_value(ptr @.str.56)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp3

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.val4 = load i32, ptr %start, align 4
  %calltmp5 = call i32 @std__json__value_end(ptr %source.val, i32 %start.val4)
  store i32 %calltmp5, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp6 = icmp slt i32 %end_pos.val, 0
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont10

then8:                                            ; preds = %ifcont
  %calltmp9 = call %JsonValue @std__json__invalid_value(ptr @.str.57)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp9

ifcont10:                                         ; preds = %ifcont
  %source.addr11 = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 2
  %source.val12 = load ptr, ptr %source.addr11, align 8
  %root.addr = getelementptr inbounds %JsonValue, ptr %obj1, i32 0, i32 1
  %root.val = load ptr, ptr %root.addr, align 8
  %start.val13 = load i32, ptr %start, align 4
  %end_pos.val14 = load i32, ptr %end_pos, align 4
  %calltmp15 = call %JsonValue @std__json__make_view(ptr %source.val12, ptr %root.val, i32 %start.val13, i32 %end_pos.val14, i1 false)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp15
}

define internal ptr @std__json__decode_string_slice(ptr %source, i32 %start, i32 %end_pos) {
entry:
  %esc = alloca i32, align 4
  %ch = alloca i32, align 4
  %j = alloca i32, align 4
  %i = alloca i32, align 4
  %out = alloca ptr, align 8
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %end_pos3 = alloca i32, align 4
  store i32 %end_pos, ptr %end_pos3, align 4
  call void @yc_frame_push()
  %start.val = load i32, ptr %start2, align 4
  %cmptmp = icmp slt i32 %start.val, 0
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end5, label %lor.rhs4

lor.rhs:                                          ; preds = %lor.end5
  %source.val = load ptr, ptr %source1, align 8
  %start.val9 = load i32, ptr %start2, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %start.val9 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp10 = icmp ne i32 %string.index.i32, 34
  %1 = zext i1 %cmptmp10 to i32
  %rhsbool11 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp12 = phi i1 [ true, %lor.end5 ], [ %rhsbool11, %lor.rhs ]
  %2 = zext i1 %lortmp12 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %entry
  %end_pos.val = load i32, ptr %end_pos3, align 4
  %start.val6 = load i32, ptr %start2, align 4
  %cmptmp7 = icmp sle i32 %end_pos.val, %start.val6
  %3 = zext i1 %cmptmp7 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs4 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool8 = icmp ne i32 %4, 0
  br i1 %lhsbool8, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %lor.end
  %end_pos.val13 = load i32, ptr %end_pos3, align 4
  %start.val14 = load i32, ptr %start2, align 4
  %subtmp = sub i32 %end_pos.val13, %start.val14
  %addtmp = add i32 %subtmp, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp, ptr %out, align 8
  %start.val15 = load i32, ptr %start2, align 4
  %addtmp16 = add i32 %start.val15, 1
  store i32 %addtmp16, ptr %i, align 4
  store i32 0, ptr %j, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %end_pos.val17 = load i32, ptr %end_pos3, align 4
  %subtmp18 = sub i32 %end_pos.val17, 1
  %cmptmp19 = icmp slt i32 %i.val, %subtmp18
  %5 = zext i1 %cmptmp19 to i32
  %forcond = icmp ne i32 %5, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val20 = load ptr, ptr %source1, align 8
  %i.val21 = load i32, ptr %i, align 4
  %string.local.ptr22 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6423 = sext i32 %i.val21 to i64
  %string.index.ptr24 = getelementptr inbounds i8, ptr %string.local.ptr22, i64 %string.index.ptr.idx.i6423
  %string.index.load25 = load i8, ptr %string.index.ptr24, align 1
  %string.index.i3226 = zext i8 %string.index.load25 to i32
  store i32 %string.index.i3226, ptr %ch, align 4
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp27 = icmp eq i32 %ch.val, 92
  %6 = zext i1 %cmptmp27 to i32
  %ifcond28 = icmp ne i32 %6, 0
  br i1 %ifcond28, label %then29, label %else98

for.inc:                                          ; preds = %ifcont105
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %out.val108 = load ptr, ptr %out, align 8
  %runtime.move109 = call ptr @yc_move_to_parent(ptr %out.val108)
  call void @yc_frame_pop()
  ret ptr %runtime.move109

then29:                                           ; preds = %for.body
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  %source.val30 = load ptr, ptr %source1, align 8
  %i.val31 = load i32, ptr %i, align 4
  %string.local.ptr32 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6433 = sext i32 %i.val31 to i64
  %string.index.ptr34 = getelementptr inbounds i8, ptr %string.local.ptr32, i64 %string.index.ptr.idx.i6433
  %string.index.load35 = load i8, ptr %string.index.ptr34, align 1
  %string.index.i3236 = zext i8 %string.index.load35 to i32
  store i32 %string.index.i3236, ptr %esc, align 4
  %esc.val = load i32, ptr %esc, align 4
  %cmptmp37 = icmp eq i32 %esc.val, 110
  %7 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %7, 0
  br i1 %ifcond38, label %then39, label %else

then39:                                           ; preds = %then29
  %out.val = load ptr, ptr %out, align 8
  %j.val = load i32, ptr %j, align 4
  %string.index.addr.idx.i64 = sext i32 %j.val to i64
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 %string.index.addr.idx.i64
  store i8 10, ptr %string.index.addr, align 1
  br label %ifcont97

else:                                             ; preds = %then29
  %esc.val40 = load i32, ptr %esc, align 4
  %cmptmp41 = icmp eq i32 %esc.val40, 114
  %8 = zext i1 %cmptmp41 to i32
  %ifcond42 = icmp ne i32 %8, 0
  br i1 %ifcond42, label %then43, label %else48

then43:                                           ; preds = %else
  %out.val44 = load ptr, ptr %out, align 8
  %j.val45 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6446 = sext i32 %j.val45 to i64
  %string.index.addr47 = getelementptr inbounds i8, ptr %out.val44, i64 %string.index.addr.idx.i6446
  store i8 13, ptr %string.index.addr47, align 1
  br label %ifcont96

else48:                                           ; preds = %else
  %esc.val49 = load i32, ptr %esc, align 4
  %cmptmp50 = icmp eq i32 %esc.val49, 116
  %9 = zext i1 %cmptmp50 to i32
  %ifcond51 = icmp ne i32 %9, 0
  br i1 %ifcond51, label %then52, label %else57

then52:                                           ; preds = %else48
  %out.val53 = load ptr, ptr %out, align 8
  %j.val54 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6455 = sext i32 %j.val54 to i64
  %string.index.addr56 = getelementptr inbounds i8, ptr %out.val53, i64 %string.index.addr.idx.i6455
  store i8 9, ptr %string.index.addr56, align 1
  br label %ifcont95

else57:                                           ; preds = %else48
  %esc.val58 = load i32, ptr %esc, align 4
  %cmptmp59 = icmp eq i32 %esc.val58, 34
  %10 = zext i1 %cmptmp59 to i32
  %ifcond60 = icmp ne i32 %10, 0
  br i1 %ifcond60, label %then61, label %else66

then61:                                           ; preds = %else57
  %out.val62 = load ptr, ptr %out, align 8
  %j.val63 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6464 = sext i32 %j.val63 to i64
  %string.index.addr65 = getelementptr inbounds i8, ptr %out.val62, i64 %string.index.addr.idx.i6464
  store i8 34, ptr %string.index.addr65, align 1
  br label %ifcont94

else66:                                           ; preds = %else57
  %esc.val67 = load i32, ptr %esc, align 4
  %cmptmp68 = icmp eq i32 %esc.val67, 92
  %11 = zext i1 %cmptmp68 to i32
  %ifcond69 = icmp ne i32 %11, 0
  br i1 %ifcond69, label %then70, label %else75

then70:                                           ; preds = %else66
  %out.val71 = load ptr, ptr %out, align 8
  %j.val72 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6473 = sext i32 %j.val72 to i64
  %string.index.addr74 = getelementptr inbounds i8, ptr %out.val71, i64 %string.index.addr.idx.i6473
  store i8 92, ptr %string.index.addr74, align 1
  br label %ifcont93

else75:                                           ; preds = %else66
  %esc.val76 = load i32, ptr %esc, align 4
  %cmptmp77 = icmp eq i32 %esc.val76, 117
  %12 = zext i1 %cmptmp77 to i32
  %ifcond78 = icmp ne i32 %12, 0
  br i1 %ifcond78, label %then79, label %else86

then79:                                           ; preds = %else75
  %out.val80 = load ptr, ptr %out, align 8
  %j.val81 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6482 = sext i32 %j.val81 to i64
  %string.index.addr83 = getelementptr inbounds i8, ptr %out.val80, i64 %string.index.addr.idx.i6482
  store i8 63, ptr %string.index.addr83, align 1
  %compound.current84 = load i32, ptr %i, align 4
  %compound.add85 = add i32 %compound.current84, 4
  store i32 %compound.add85, ptr %i, align 4
  br label %ifcont92

else86:                                           ; preds = %else75
  %out.val87 = load ptr, ptr %out, align 8
  %j.val88 = load i32, ptr %j, align 4
  %string.index.addr.idx.i6489 = sext i32 %j.val88 to i64
  %string.index.addr90 = getelementptr inbounds i8, ptr %out.val87, i64 %string.index.addr.idx.i6489
  %esc.val91 = load i32, ptr %esc, align 4
  %assign_trunc = trunc i32 %esc.val91 to i8
  store i8 %assign_trunc, ptr %string.index.addr90, align 1
  br label %ifcont92

ifcont92:                                         ; preds = %else86, %then79
  br label %ifcont93

ifcont93:                                         ; preds = %ifcont92, %then70
  br label %ifcont94

ifcont94:                                         ; preds = %ifcont93, %then61
  br label %ifcont95

ifcont95:                                         ; preds = %ifcont94, %then52
  br label %ifcont96

ifcont96:                                         ; preds = %ifcont95, %then43
  br label %ifcont97

ifcont97:                                         ; preds = %ifcont96, %then39
  br label %ifcont105

else98:                                           ; preds = %for.body
  %out.val99 = load ptr, ptr %out, align 8
  %j.val100 = load i32, ptr %j, align 4
  %string.index.addr.idx.i64101 = sext i32 %j.val100 to i64
  %string.index.addr102 = getelementptr inbounds i8, ptr %out.val99, i64 %string.index.addr.idx.i64101
  %ch.val103 = load i32, ptr %ch, align 4
  %assign_trunc104 = trunc i32 %ch.val103 to i8
  store i8 %assign_trunc104, ptr %string.index.addr102, align 1
  br label %ifcont105

ifcont105:                                        ; preds = %else98, %ifcont97
  %compound.current106 = load i32, ptr %j, align 4
  %compound.add107 = add i32 %compound.current106, 1
  store i32 %compound.add107, ptr %j, align 4
  br label %for.inc
}

define ptr @std__json__get_string(%JsonValue %obj, ptr %key) {
entry:
  %value = alloca %JsonValue, align 8
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call %JsonValue @std__json__get(%JsonValue %obj.val, ptr %key.val)
  store %JsonValue %calltmp, ptr %value, align 8
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 3
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %calltmp3 = call ptr @std__json__decode_string_slice(ptr %source.val, i32 %start.val, i32 %end.val)
  %runtime.move4 = call ptr @yc_move_to_parent(ptr %calltmp3)
  call void @yc_frame_pop()
  ret ptr %runtime.move4
}

define internal i32 @std__json__parse_i32_slice(ptr %source, i32 %start, i32 %end_pos) {
entry:
  %value = alloca i32, align 4
  %sign = alloca i32, align 4
  %i = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %end_pos3 = alloca i32, align 4
  store i32 %end_pos, ptr %end_pos3, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std__json__skip_ws(ptr %source.val, i32 %start.val)
  store i32 %calltmp, ptr %i, align 4
  store i32 1, ptr %sign, align 4
  %i.val = load i32, ptr %i, align 4
  %end_pos.val = load i32, ptr %end_pos3, align 4
  %cmptmp = icmp slt i32 %i.val, %end_pos.val
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %source.val4 = load ptr, ptr %source1, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val5 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp6 = icmp eq i32 %string.index.i32, 45
  %1 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %landtmp = phi i1 [ false, %entry ], [ %rhsbool, %land.rhs ]
  %2 = zext i1 %landtmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %land.end
  store i32 -1, ptr %sign, align 4
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  br label %ifcont

ifcont:                                           ; preds = %then, %land.end
  store i32 0, ptr %value, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val11 = load i32, ptr %i, align 4
  %end_pos.val12 = load i32, ptr %end_pos3, align 4
  %cmptmp13 = icmp slt i32 %i.val11, %end_pos.val12
  %3 = zext i1 %cmptmp13 to i32
  %lhsbool14 = icmp ne i32 %3, 0
  br i1 %lhsbool14, label %land.rhs9, label %land.end10

for.body:                                         ; preds = %land.end8
  %value.val = load i32, ptr %value, align 4
  %multmp = mul i32 %value.val, 10
  %source.val36 = load ptr, ptr %source1, align 8
  %i.val37 = load i32, ptr %i, align 4
  %string.local.ptr38 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6439 = sext i32 %i.val37 to i64
  %string.index.ptr40 = getelementptr inbounds i8, ptr %string.local.ptr38, i64 %string.index.ptr.idx.i6439
  %string.index.load41 = load i8, ptr %string.index.ptr40, align 1
  %string.index.i3242 = zext i8 %string.index.load41 to i32
  %subtmp = sub i32 %string.index.i3242, 48
  %addtmp = add i32 %multmp, %subtmp
  store i32 %addtmp, ptr %value, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end8
  %value.val43 = load i32, ptr %value, align 4
  %sign.val = load i32, ptr %sign, align 4
  %multmp44 = mul i32 %value.val43, %sign.val
  call void @yc_frame_pop()
  ret i32 %multmp44

land.rhs7:                                        ; preds = %land.end10
  %source.val26 = load ptr, ptr %source1, align 8
  %i.val27 = load i32, ptr %i, align 4
  %string.local.ptr28 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6429 = sext i32 %i.val27 to i64
  %string.index.ptr30 = getelementptr inbounds i8, ptr %string.local.ptr28, i64 %string.index.ptr.idx.i6429
  %string.index.load31 = load i8, ptr %string.index.ptr30, align 1
  %string.index.i3232 = zext i8 %string.index.load31 to i32
  %cmptmp33 = icmp sle i32 %string.index.i3232, 57
  %4 = zext i1 %cmptmp33 to i32
  %rhsbool34 = icmp ne i32 %4, 0
  br label %land.end8

land.end8:                                        ; preds = %land.rhs7, %land.end10
  %landtmp35 = phi i1 [ false, %land.end10 ], [ %rhsbool34, %land.rhs7 ]
  %5 = zext i1 %landtmp35 to i32
  %forcond = icmp ne i32 %5, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs9:                                        ; preds = %for.cond
  %source.val15 = load ptr, ptr %source1, align 8
  %i.val16 = load i32, ptr %i, align 4
  %string.local.ptr17 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6418 = sext i32 %i.val16 to i64
  %string.index.ptr19 = getelementptr inbounds i8, ptr %string.local.ptr17, i64 %string.index.ptr.idx.i6418
  %string.index.load20 = load i8, ptr %string.index.ptr19, align 1
  %string.index.i3221 = zext i8 %string.index.load20 to i32
  %cmptmp22 = icmp sge i32 %string.index.i3221, 48
  %6 = zext i1 %cmptmp22 to i32
  %rhsbool23 = icmp ne i32 %6, 0
  br label %land.end10

land.end10:                                       ; preds = %land.rhs9, %for.cond
  %landtmp24 = phi i1 [ false, %for.cond ], [ %rhsbool23, %land.rhs9 ]
  %7 = zext i1 %landtmp24 to i32
  %lhsbool25 = icmp ne i32 %7, 0
  br i1 %lhsbool25, label %land.rhs7, label %land.end8
}

define i32 @std__json__get_i32(%JsonValue %obj, ptr %key) {
entry:
  %value = alloca %JsonValue, align 8
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call %JsonValue @std__json__get(%JsonValue %obj.val, ptr %key.val)
  store %JsonValue %calltmp, ptr %value, align 8
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 6
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %calltmp3 = call i32 @std__json__parse_i32_slice(ptr %source.val, i32 %start.val, i32 %end.val)
  call void @yc_frame_pop()
  ret i32 %calltmp3
}

define i1 @std__json__get_bool(%JsonValue %obj, ptr %key) {
entry:
  %value = alloca %JsonValue, align 8
  %obj1 = alloca %JsonValue, align 8
  store %JsonValue %obj, ptr %obj1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %obj.val = load %JsonValue, ptr %obj1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call %JsonValue @std__json__get(%JsonValue %obj.val, ptr %key.val)
  store %JsonValue %calltmp, ptr %value, align 8
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 4
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %start.val to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp3 = icmp eq i32 %string.expr.index.i32, 116
  %1 = zext i1 %cmptmp3 to i32
  %return.intcast = trunc i32 %1 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define %JsonValue @std__json__at(%JsonValue %array, i32 %index) {
entry:
  %end_pos = alloca i32, align 4
  %current = alloca i32, align 4
  %i = alloca i32, align 4
  %array1 = alloca %JsonValue, align 8
  store %JsonValue %array, ptr %array1, align 8
  %index2 = alloca i32, align 4
  store i32 %index, ptr %index2, align 4
  call void @yc_frame_push()
  %kind.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp = icmp ne i32 %kind.val, 2
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %source.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp3 = icmp eq ptr %source.val, null
  %1 = zext i1 %cmptmp3 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %calltmp = call %JsonValue @std__json__invalid_value(ptr @.str.58)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp

ifcont:                                           ; preds = %lor.end
  %source.addr4 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val5 = load ptr, ptr %source.addr4, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %addtmp = add i32 %start.val, 1
  %calltmp6 = call i32 @std__json__skip_ws(ptr %source.val5, i32 %addtmp)
  store i32 %calltmp6, ptr %i, align 4
  store i32 0, ptr %current, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %cmptmp7 = icmp slt i32 %i.val, %end.val
  %3 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %3, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.addr8 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val9 = load ptr, ptr %source.addr8, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val10 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val9, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp11 = icmp eq i32 %string.expr.index.i32, 93
  %4 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %4, 0
  br i1 %ifcond12, label %then13, label %ifcont15

for.inc:                                          ; preds = %ifcont59
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %calltmp60 = call %JsonValue @std__json__invalid_value(ptr @.str.61)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp60

then13:                                           ; preds = %for.body
  %calltmp14 = call %JsonValue @std__json__invalid_value(ptr @.str.59)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp14

ifcont15:                                         ; preds = %for.body
  %source.addr16 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val17 = load ptr, ptr %source.addr16, align 8
  %i.val18 = load i32, ptr %i, align 4
  %calltmp19 = call i32 @std__json__value_end(ptr %source.val17, i32 %i.val18)
  store i32 %calltmp19, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp20 = icmp slt i32 %end_pos.val, 0
  %5 = zext i1 %cmptmp20 to i32
  %ifcond21 = icmp ne i32 %5, 0
  br i1 %ifcond21, label %then22, label %ifcont24

then22:                                           ; preds = %ifcont15
  %calltmp23 = call %JsonValue @std__json__invalid_value(ptr @.str.60)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp23

ifcont24:                                         ; preds = %ifcont15
  %current.val = load i32, ptr %current, align 4
  %index.val = load i32, ptr %index2, align 4
  %cmptmp25 = icmp eq i32 %current.val, %index.val
  %6 = zext i1 %cmptmp25 to i32
  %ifcond26 = icmp ne i32 %6, 0
  br i1 %ifcond26, label %then27, label %ifcont33

then27:                                           ; preds = %ifcont24
  %source.addr28 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val29 = load ptr, ptr %source.addr28, align 8
  %root.addr = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 1
  %root.val = load ptr, ptr %root.addr, align 8
  %i.val30 = load i32, ptr %i, align 4
  %end_pos.val31 = load i32, ptr %end_pos, align 4
  %calltmp32 = call %JsonValue @std__json__make_view(ptr %source.val29, ptr %root.val, i32 %i.val30, i32 %end_pos.val31, i1 false)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %JsonValue %calltmp32

ifcont33:                                         ; preds = %ifcont24
  %compound.current = load i32, ptr %current, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %current, align 4
  %source.addr34 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val35 = load ptr, ptr %source.addr34, align 8
  %end_pos.val36 = load i32, ptr %end_pos, align 4
  %calltmp37 = call i32 @std__json__skip_ws(ptr %source.val35, i32 %end_pos.val36)
  store i32 %calltmp37, ptr %i, align 4
  %i.val38 = load i32, ptr %i, align 4
  %end.addr39 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 4
  %end.val40 = load i32, ptr %end.addr39, align 4
  %cmptmp41 = icmp slt i32 %i.val38, %end.val40
  %7 = zext i1 %cmptmp41 to i32
  %lhsbool42 = icmp ne i32 %7, 0
  br i1 %lhsbool42, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont33
  %source.addr43 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val44 = load ptr, ptr %source.addr43, align 8
  %i.val45 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6446 = sext i32 %i.val45 to i64
  %string.expr.index.ptr47 = getelementptr inbounds i8, ptr %source.val44, i64 %string.expr.index.ptr.idx.i6446
  %string.expr.index.load48 = load i8, ptr %string.expr.index.ptr47, align 1
  %string.expr.index.i3249 = zext i8 %string.expr.index.load48 to i32
  %cmptmp50 = icmp eq i32 %string.expr.index.i3249, 44
  %8 = zext i1 %cmptmp50 to i32
  %rhsbool51 = icmp ne i32 %8, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont33
  %landtmp = phi i1 [ false, %ifcont33 ], [ %rhsbool51, %land.rhs ]
  %9 = zext i1 %landtmp to i32
  %ifcond52 = icmp ne i32 %9, 0
  br i1 %ifcond52, label %then53, label %ifcont59

then53:                                           ; preds = %land.end
  %source.addr54 = getelementptr inbounds %JsonValue, ptr %array1, i32 0, i32 2
  %source.val55 = load ptr, ptr %source.addr54, align 8
  %i.val56 = load i32, ptr %i, align 4
  %addtmp57 = add i32 %i.val56, 1
  %calltmp58 = call i32 @std__json__skip_ws(ptr %source.val55, i32 %addtmp57)
  store i32 %calltmp58, ptr %i, align 4
  br label %ifcont59

ifcont59:                                         ; preds = %then53, %land.end
  br label %for.inc
}

define i32 @std__json__len(%JsonValue %value) {
entry:
  %value_stop = alloca i32, align 4
  %value_start = alloca i32, align 4
  %after_key = alloca i32, align 4
  %key_end = alloca i32, align 4
  %i62 = alloca i32, align 4
  %count55 = alloca i32, align 4
  %end_pos = alloca i32, align 4
  %i = alloca i32, align 4
  %count = alloca i32, align 4
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %source.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp = icmp eq ptr %source.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  %kind.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val = load i32, ptr %kind.addr, align 4
  %cmptmp2 = icmp eq i32 %kind.val, 2
  %1 = zext i1 %cmptmp2 to i32
  %ifcond3 = icmp ne i32 %1, 0
  br i1 %ifcond3, label %then4, label %ifcont49

then4:                                            ; preds = %ifcont
  store i32 0, ptr %count, align 4
  %source.addr5 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val6 = load ptr, ptr %source.addr5, align 8
  %start.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val = load i32, ptr %start.addr, align 4
  %addtmp = add i32 %start.val, 1
  %calltmp = call i32 @std__json__skip_ws(ptr %source.val6, i32 %addtmp)
  store i32 %calltmp, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %then4
  %i.val = load i32, ptr %i, align 4
  %end.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val = load i32, ptr %end.addr, align 4
  %cmptmp7 = icmp slt i32 %i.val, %end.val
  %2 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.addr8 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val9 = load ptr, ptr %source.addr8, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val10 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %source.val9, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %cmptmp11 = icmp eq i32 %string.expr.index.i32, 93
  %3 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %3, 0
  br i1 %ifcond12, label %then13, label %ifcont14

for.inc:                                          ; preds = %ifcont47
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %count.val48 = load i32, ptr %count, align 4
  call void @yc_frame_pop()
  ret i32 %count.val48

then13:                                           ; preds = %for.body
  %count.val = load i32, ptr %count, align 4
  call void @yc_frame_pop()
  ret i32 %count.val

ifcont14:                                         ; preds = %for.body
  %source.addr15 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val16 = load ptr, ptr %source.addr15, align 8
  %i.val17 = load i32, ptr %i, align 4
  %calltmp18 = call i32 @std__json__value_end(ptr %source.val16, i32 %i.val17)
  store i32 %calltmp18, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp19 = icmp slt i32 %end_pos.val, 0
  %4 = zext i1 %cmptmp19 to i32
  %ifcond20 = icmp ne i32 %4, 0
  br i1 %ifcond20, label %then21, label %ifcont23

then21:                                           ; preds = %ifcont14
  %count.val22 = load i32, ptr %count, align 4
  call void @yc_frame_pop()
  ret i32 %count.val22

ifcont23:                                         ; preds = %ifcont14
  %compound.current = load i32, ptr %count, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %count, align 4
  %source.addr24 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val25 = load ptr, ptr %source.addr24, align 8
  %end_pos.val26 = load i32, ptr %end_pos, align 4
  %calltmp27 = call i32 @std__json__skip_ws(ptr %source.val25, i32 %end_pos.val26)
  store i32 %calltmp27, ptr %i, align 4
  %i.val28 = load i32, ptr %i, align 4
  %end.addr29 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val30 = load i32, ptr %end.addr29, align 4
  %cmptmp31 = icmp slt i32 %i.val28, %end.val30
  %5 = zext i1 %cmptmp31 to i32
  %lhsbool = icmp ne i32 %5, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont23
  %source.addr32 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val33 = load ptr, ptr %source.addr32, align 8
  %i.val34 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6435 = sext i32 %i.val34 to i64
  %string.expr.index.ptr36 = getelementptr inbounds i8, ptr %source.val33, i64 %string.expr.index.ptr.idx.i6435
  %string.expr.index.load37 = load i8, ptr %string.expr.index.ptr36, align 1
  %string.expr.index.i3238 = zext i8 %string.expr.index.load37 to i32
  %cmptmp39 = icmp eq i32 %string.expr.index.i3238, 44
  %6 = zext i1 %cmptmp39 to i32
  %rhsbool = icmp ne i32 %6, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont23
  %landtmp = phi i1 [ false, %ifcont23 ], [ %rhsbool, %land.rhs ]
  %7 = zext i1 %landtmp to i32
  %ifcond40 = icmp ne i32 %7, 0
  br i1 %ifcond40, label %then41, label %ifcont47

then41:                                           ; preds = %land.end
  %source.addr42 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val43 = load ptr, ptr %source.addr42, align 8
  %i.val44 = load i32, ptr %i, align 4
  %addtmp45 = add i32 %i.val44, 1
  %calltmp46 = call i32 @std__json__skip_ws(ptr %source.val43, i32 %addtmp45)
  store i32 %calltmp46, ptr %i, align 4
  br label %ifcont47

ifcont47:                                         ; preds = %then41, %land.end
  br label %for.inc

ifcont49:                                         ; preds = %ifcont
  %kind.addr50 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 0
  %kind.val51 = load i32, ptr %kind.addr50, align 4
  %cmptmp52 = icmp eq i32 %kind.val51, 1
  %8 = zext i1 %cmptmp52 to i32
  %ifcond53 = icmp ne i32 %8, 0
  br i1 %ifcond53, label %then54, label %ifcont142

then54:                                           ; preds = %ifcont49
  store i32 0, ptr %count55, align 4
  %source.addr56 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val57 = load ptr, ptr %source.addr56, align 8
  %start.addr58 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 3
  %start.val59 = load i32, ptr %start.addr58, align 4
  %addtmp60 = add i32 %start.val59, 1
  %calltmp61 = call i32 @std__json__skip_ws(ptr %source.val57, i32 %addtmp60)
  store i32 %calltmp61, ptr %i62, align 4
  br label %for.cond63

for.cond63:                                       ; preds = %for.inc65, %then54
  %i.val67 = load i32, ptr %i62, align 4
  %end.addr68 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val69 = load i32, ptr %end.addr68, align 4
  %cmptmp70 = icmp slt i32 %i.val67, %end.val69
  %9 = zext i1 %cmptmp70 to i32
  %forcond71 = icmp ne i32 %9, 0
  br i1 %forcond71, label %for.body64, label %for.after66

for.body64:                                       ; preds = %for.cond63
  %source.addr72 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val73 = load ptr, ptr %source.addr72, align 8
  %i.val74 = load i32, ptr %i62, align 4
  %string.expr.index.ptr.idx.i6475 = sext i32 %i.val74 to i64
  %string.expr.index.ptr76 = getelementptr inbounds i8, ptr %source.val73, i64 %string.expr.index.ptr.idx.i6475
  %string.expr.index.load77 = load i8, ptr %string.expr.index.ptr76, align 1
  %string.expr.index.i3278 = zext i8 %string.expr.index.load77 to i32
  %cmptmp79 = icmp eq i32 %string.expr.index.i3278, 125
  %10 = zext i1 %cmptmp79 to i32
  %ifcond80 = icmp ne i32 %10, 0
  br i1 %ifcond80, label %then81, label %ifcont83

for.inc65:                                        ; preds = %ifcont140
  br label %for.cond63

for.after66:                                      ; preds = %for.cond63
  %count.val141 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val141

then81:                                           ; preds = %for.body64
  %count.val82 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val82

ifcont83:                                         ; preds = %for.body64
  %source.addr84 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val85 = load ptr, ptr %source.addr84, align 8
  %i.val86 = load i32, ptr %i62, align 4
  %calltmp87 = call i32 @std__json__string_end(ptr %source.val85, i32 %i.val86)
  store i32 %calltmp87, ptr %key_end, align 4
  %key_end.val = load i32, ptr %key_end, align 4
  %cmptmp88 = icmp slt i32 %key_end.val, 0
  %11 = zext i1 %cmptmp88 to i32
  %ifcond89 = icmp ne i32 %11, 0
  br i1 %ifcond89, label %then90, label %ifcont92

then90:                                           ; preds = %ifcont83
  %count.val91 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val91

ifcont92:                                         ; preds = %ifcont83
  %source.addr93 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val94 = load ptr, ptr %source.addr93, align 8
  %key_end.val95 = load i32, ptr %key_end, align 4
  %addtmp96 = add i32 %key_end.val95, 1
  %calltmp97 = call i32 @std__json__skip_ws(ptr %source.val94, i32 %addtmp96)
  store i32 %calltmp97, ptr %after_key, align 4
  %source.addr98 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val99 = load ptr, ptr %source.addr98, align 8
  %after_key.val = load i32, ptr %after_key, align 4
  %addtmp100 = add i32 %after_key.val, 1
  %calltmp101 = call i32 @std__json__skip_ws(ptr %source.val99, i32 %addtmp100)
  store i32 %calltmp101, ptr %value_start, align 4
  %source.addr102 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val103 = load ptr, ptr %source.addr102, align 8
  %value_start.val = load i32, ptr %value_start, align 4
  %calltmp104 = call i32 @std__json__value_end(ptr %source.val103, i32 %value_start.val)
  store i32 %calltmp104, ptr %value_stop, align 4
  %value_stop.val = load i32, ptr %value_stop, align 4
  %cmptmp105 = icmp slt i32 %value_stop.val, 0
  %12 = zext i1 %cmptmp105 to i32
  %ifcond106 = icmp ne i32 %12, 0
  br i1 %ifcond106, label %then107, label %ifcont109

then107:                                          ; preds = %ifcont92
  %count.val108 = load i32, ptr %count55, align 4
  call void @yc_frame_pop()
  ret i32 %count.val108

ifcont109:                                        ; preds = %ifcont92
  %compound.current110 = load i32, ptr %count55, align 4
  %compound.add111 = add i32 %compound.current110, 1
  store i32 %compound.add111, ptr %count55, align 4
  %source.addr112 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val113 = load ptr, ptr %source.addr112, align 8
  %value_stop.val114 = load i32, ptr %value_stop, align 4
  %calltmp115 = call i32 @std__json__skip_ws(ptr %source.val113, i32 %value_stop.val114)
  store i32 %calltmp115, ptr %i62, align 4
  %i.val118 = load i32, ptr %i62, align 4
  %end.addr119 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 4
  %end.val120 = load i32, ptr %end.addr119, align 4
  %cmptmp121 = icmp slt i32 %i.val118, %end.val120
  %13 = zext i1 %cmptmp121 to i32
  %lhsbool122 = icmp ne i32 %13, 0
  br i1 %lhsbool122, label %land.rhs116, label %land.end117

land.rhs116:                                      ; preds = %ifcont109
  %source.addr123 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val124 = load ptr, ptr %source.addr123, align 8
  %i.val125 = load i32, ptr %i62, align 4
  %string.expr.index.ptr.idx.i64126 = sext i32 %i.val125 to i64
  %string.expr.index.ptr127 = getelementptr inbounds i8, ptr %source.val124, i64 %string.expr.index.ptr.idx.i64126
  %string.expr.index.load128 = load i8, ptr %string.expr.index.ptr127, align 1
  %string.expr.index.i32129 = zext i8 %string.expr.index.load128 to i32
  %cmptmp130 = icmp eq i32 %string.expr.index.i32129, 44
  %14 = zext i1 %cmptmp130 to i32
  %rhsbool131 = icmp ne i32 %14, 0
  br label %land.end117

land.end117:                                      ; preds = %land.rhs116, %ifcont109
  %landtmp132 = phi i1 [ false, %ifcont109 ], [ %rhsbool131, %land.rhs116 ]
  %15 = zext i1 %landtmp132 to i32
  %ifcond133 = icmp ne i32 %15, 0
  br i1 %ifcond133, label %then134, label %ifcont140

then134:                                          ; preds = %land.end117
  %source.addr135 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val136 = load ptr, ptr %source.addr135, align 8
  %i.val137 = load i32, ptr %i62, align 4
  %addtmp138 = add i32 %i.val137, 1
  %calltmp139 = call i32 @std__json__skip_ws(ptr %source.val136, i32 %addtmp138)
  store i32 %calltmp139, ptr %i62, align 4
  br label %ifcont140

ifcont140:                                        ; preds = %then134, %land.end117
  br label %for.inc65

ifcont142:                                        ; preds = %ifcont49
  call void @yc_frame_pop()
  ret i32 0
}

define void @std__json__free(%JsonValue %value) {
entry:
  %value1 = alloca %JsonValue, align 8
  store %JsonValue %value, ptr %value1, align 8
  call void @yc_frame_push()
  %owns.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 5
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond = icmp ne i1 %owns.val, false
  br i1 %ifcond, label %then, label %ifcont12

then:                                             ; preds = %entry
  %root.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 1
  %root.val = load ptr, ptr %root.addr, align 8
  %cmptmp = icmp ne ptr %root.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond2 = icmp ne i32 %0, 0
  br i1 %ifcond2, label %then3, label %else

then3:                                            ; preds = %then
  %root.addr4 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 1
  %root.val5 = load ptr, ptr %root.addr4, align 8
  call void @std__mem__free(ptr %root.val5)
  br label %ifcont11

else:                                             ; preds = %then
  %source.addr = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val = load ptr, ptr %source.addr, align 8
  %cmptmp6 = icmp ne ptr %source.val, null
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont

then8:                                            ; preds = %else
  %source.addr9 = getelementptr inbounds %JsonValue, ptr %value1, i32 0, i32 2
  %source.val10 = load ptr, ptr %source.addr9, align 8
  call void @std__mem__free(ptr %source.val10)
  br label %ifcont

ifcont:                                           ; preds = %then8, %else
  br label %ifcont11

ifcont11:                                         ; preds = %ifcont, %then3
  br label %ifcont12

ifcont12:                                         ; preds = %ifcont11, %entry
  call void @yc_frame_pop()
  ret void
}

define i1 @std__json__method_is(ptr %message, ptr %method) {
entry:
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %method2 = alloca ptr, align 8
  store ptr %method, ptr %method2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %method.val = load ptr, ptr %method2, align 8
  %calltmp = call i1 @std__text__contains(ptr %message.val, ptr %method.val)
  call void @yc_frame_pop()
  ret i1 %calltmp
}

define i32 @std__json__field_value_start(ptr %message, ptr %key) {
entry:
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %key_pos = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std__text__find(ptr %message.val, ptr %key.val)
  store i32 %calltmp, ptr %key_pos, align 4
  %key_pos.val = load i32, ptr %key_pos, align 4
  %cmptmp = icmp slt i32 %key_pos.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %key_pos.val3 = load i32, ptr %key_pos, align 4
  %key.val4 = load ptr, ptr %key2, align 8
  %calltmp5 = call i32 @std__text__len(ptr %key.val4)
  %addtmp = add i32 %key_pos.val3, %calltmp5
  store i32 %addtmp, ptr %i, align 4
  %message.val6 = load ptr, ptr %message1, align 8
  %calltmp7 = call i32 @std__text__len(ptr %message.val6)
  store i32 %calltmp7, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp8 = icmp slt i32 %i.val, %n.val
  %1 = zext i1 %cmptmp8 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val12 = load i32, ptr %i, align 4
  %n.val13 = load i32, ptr %n, align 4
  %cmptmp14 = icmp sge i32 %i.val12, %n.val13
  %2 = zext i1 %cmptmp14 to i32
  %ifcond15 = icmp ne i32 %2, 0
  br i1 %ifcond15, label %then16, label %ifcont17

land.rhs:                                         ; preds = %for.cond
  %message.val9 = load ptr, ptr %message1, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val10 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp11 = icmp ne i32 %string.index.i32, 58
  %3 = zext i1 %cmptmp11 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs ]
  %4 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %4, 0
  br i1 %forcond, label %for.body, label %for.after

then16:                                           ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1

ifcont17:                                         ; preds = %for.after
  %message.val18 = load ptr, ptr %message1, align 8
  %i.val19 = load i32, ptr %i, align 4
  %addtmp20 = add i32 %i.val19, 1
  %calltmp21 = call i32 @std__json__skip_ws(ptr %message.val18, i32 %addtmp20)
  call void @yc_frame_pop()
  ret i32 %calltmp21
}

define i32 @std__json__field_i32(ptr %message, ptr %key) {
entry:
  %value = alloca i32, align 4
  %sign = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std__json__field_value_start(ptr %message.val, ptr %key.val)
  store i32 %calltmp, ptr %i, align 4
  %i.val = load i32, ptr %i, align 4
  %cmptmp = icmp slt i32 %i.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  %message.val3 = load ptr, ptr %message1, align 8
  %calltmp4 = call i32 @std__text__len(ptr %message.val3)
  store i32 %calltmp4, ptr %n, align 4
  store i32 1, ptr %sign, align 4
  %i.val5 = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp6 = icmp slt i32 %i.val5, %n.val
  %1 = zext i1 %cmptmp6 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont
  %message.val7 = load ptr, ptr %message1, align 8
  %i.val8 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val8 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp9 = icmp eq i32 %string.index.i32, 45
  %2 = zext i1 %cmptmp9 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont
  %landtmp = phi i1 [ false, %ifcont ], [ %rhsbool, %land.rhs ]
  %3 = zext i1 %landtmp to i32
  %ifcond10 = icmp ne i32 %3, 0
  br i1 %ifcond10, label %then11, label %ifcont12

then11:                                           ; preds = %land.end
  store i32 -1, ptr %sign, align 4
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  br label %ifcont12

ifcont12:                                         ; preds = %then11, %land.end
  store i32 0, ptr %value, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont12
  %i.val17 = load i32, ptr %i, align 4
  %n.val18 = load i32, ptr %n, align 4
  %cmptmp19 = icmp slt i32 %i.val17, %n.val18
  %4 = zext i1 %cmptmp19 to i32
  %lhsbool20 = icmp ne i32 %4, 0
  br i1 %lhsbool20, label %land.rhs15, label %land.end16

for.body:                                         ; preds = %land.end14
  %value.val = load i32, ptr %value, align 4
  %multmp = mul i32 %value.val, 10
  %message.val42 = load ptr, ptr %message1, align 8
  %i.val43 = load i32, ptr %i, align 4
  %string.local.ptr44 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6445 = sext i32 %i.val43 to i64
  %string.index.ptr46 = getelementptr inbounds i8, ptr %string.local.ptr44, i64 %string.index.ptr.idx.i6445
  %string.index.load47 = load i8, ptr %string.index.ptr46, align 1
  %string.index.i3248 = zext i8 %string.index.load47 to i32
  %subtmp = sub i32 %string.index.i3248, 48
  %addtmp = add i32 %multmp, %subtmp
  store i32 %addtmp, ptr %value, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end14
  %value.val49 = load i32, ptr %value, align 4
  %sign.val = load i32, ptr %sign, align 4
  %multmp50 = mul i32 %value.val49, %sign.val
  call void @yc_frame_pop()
  ret i32 %multmp50

land.rhs13:                                       ; preds = %land.end16
  %message.val32 = load ptr, ptr %message1, align 8
  %i.val33 = load i32, ptr %i, align 4
  %string.local.ptr34 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6435 = sext i32 %i.val33 to i64
  %string.index.ptr36 = getelementptr inbounds i8, ptr %string.local.ptr34, i64 %string.index.ptr.idx.i6435
  %string.index.load37 = load i8, ptr %string.index.ptr36, align 1
  %string.index.i3238 = zext i8 %string.index.load37 to i32
  %cmptmp39 = icmp sle i32 %string.index.i3238, 57
  %5 = zext i1 %cmptmp39 to i32
  %rhsbool40 = icmp ne i32 %5, 0
  br label %land.end14

land.end14:                                       ; preds = %land.rhs13, %land.end16
  %landtmp41 = phi i1 [ false, %land.end16 ], [ %rhsbool40, %land.rhs13 ]
  %6 = zext i1 %landtmp41 to i32
  %forcond = icmp ne i32 %6, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs15:                                       ; preds = %for.cond
  %message.val21 = load ptr, ptr %message1, align 8
  %i.val22 = load i32, ptr %i, align 4
  %string.local.ptr23 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6424 = sext i32 %i.val22 to i64
  %string.index.ptr25 = getelementptr inbounds i8, ptr %string.local.ptr23, i64 %string.index.ptr.idx.i6424
  %string.index.load26 = load i8, ptr %string.index.ptr25, align 1
  %string.index.i3227 = zext i8 %string.index.load26 to i32
  %cmptmp28 = icmp sge i32 %string.index.i3227, 48
  %7 = zext i1 %cmptmp28 to i32
  %rhsbool29 = icmp ne i32 %7, 0
  br label %land.end16

land.end16:                                       ; preds = %land.rhs15, %for.cond
  %landtmp30 = phi i1 [ false, %for.cond ], [ %rhsbool29, %land.rhs15 ]
  %8 = zext i1 %landtmp30 to i32
  %lhsbool31 = icmp ne i32 %8, 0
  br i1 %lhsbool31, label %land.rhs13, label %land.end14
}

define i32 @std__json__id_i32(ptr %message) {
entry:
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %calltmp = call i32 @std__json__field_i32(ptr %message.val, ptr @.str.62)
  call void @yc_frame_pop()
  ret i32 %calltmp
}

define ptr @std__json__field_string(ptr %message, ptr %key) {
entry:
  %end_pos = alloca i32, align 4
  %n = alloca i32, align 4
  %start = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %key2 = alloca ptr, align 8
  store ptr %key, ptr %key2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %key.val = load ptr, ptr %key2, align 8
  %calltmp = call i32 @std__json__field_value_start(ptr %message.val, ptr %key.val)
  store i32 %calltmp, ptr %start, align 4
  %start.val = load i32, ptr %start, align 4
  %cmptmp = icmp slt i32 %start.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %message.val3 = load ptr, ptr %message1, align 8
  %calltmp4 = call i32 @std__text__len(ptr %message.val3)
  store i32 %calltmp4, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %start.val5 = load i32, ptr %start, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp6 = icmp slt i32 %start.val5, %n.val
  %1 = zext i1 %cmptmp6 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %start, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %start, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %start.val10 = load i32, ptr %start, align 4
  %n.val11 = load i32, ptr %n, align 4
  %cmptmp12 = icmp sge i32 %start.val10, %n.val11
  %2 = zext i1 %cmptmp12 to i32
  %ifcond13 = icmp ne i32 %2, 0
  br i1 %ifcond13, label %then14, label %ifcont16

land.rhs:                                         ; preds = %for.cond
  %message.val7 = load ptr, ptr %message1, align 8
  %start.val8 = load i32, ptr %start, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %start.val8 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp9 = icmp ne i32 %string.index.i32, 34
  %3 = zext i1 %cmptmp9 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs ]
  %4 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %4, 0
  br i1 %forcond, label %for.body, label %for.after

then14:                                           ; preds = %for.after
  %runtime.move15 = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move15

ifcont16:                                         ; preds = %for.after
  %message.val17 = load ptr, ptr %message1, align 8
  %start.val18 = load i32, ptr %start, align 4
  %calltmp19 = call i32 @std__json__string_end(ptr %message.val17, i32 %start.val18)
  store i32 %calltmp19, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp20 = icmp slt i32 %end_pos.val, 0
  %5 = zext i1 %cmptmp20 to i32
  %ifcond21 = icmp ne i32 %5, 0
  br i1 %ifcond21, label %then22, label %ifcont24

then22:                                           ; preds = %ifcont16
  %runtime.move23 = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move23

ifcont24:                                         ; preds = %ifcont16
  %message.val25 = load ptr, ptr %message1, align 8
  %start.val26 = load i32, ptr %start, align 4
  %end_pos.val27 = load i32, ptr %end_pos, align 4
  %addtmp = add i32 %end_pos.val27, 1
  %calltmp28 = call ptr @std__json__decode_string_slice(ptr %message.val25, i32 %start.val26, i32 %addtmp)
  %runtime.move29 = call ptr @yc_move_to_parent(ptr %calltmp28)
  call void @yc_frame_pop()
  ret ptr %runtime.move29
}

define i1 @std__json__method_name_is(ptr %message, ptr %name) {
entry:
  %ok = alloca i1, align 1
  %method = alloca ptr, align 8
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %name2 = alloca ptr, align 8
  store ptr %name, ptr %name2, align 8
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %calltmp = call ptr @std__json__field_string(ptr %message.val, ptr @.str.63)
  store ptr %calltmp, ptr %method, align 8
  %method.val = load ptr, ptr %method, align 8
  %cmptmp = icmp eq ptr %method.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  %method.val3 = load ptr, ptr %method, align 8
  %name.val = load ptr, ptr %name2, align 8
  %calltmp4 = call i1 @std__str__eq(ptr %method.val3, ptr %name.val)
  store i1 %calltmp4, ptr %ok, align 1
  %method.val5 = load ptr, ptr %method, align 8
  call void @std__mem__free(ptr %method.val5)
  %ok.val = load i1, ptr %ok, align 1
  call void @yc_frame_pop()
  ret i1 %ok.val
}

define i32 @std__json__content_length_at(ptr %message, i32 %start) {
entry:
  %value = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %key = alloca i32, align 4
  %message1 = alloca ptr, align 8
  store ptr %message, ptr %message1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  call void @yc_frame_push()
  %message.val = load ptr, ptr %message1, align 8
  %start.val = load i32, ptr %start2, align 4
  %calltmp = call i32 @std__text__find_from(ptr %message.val, ptr @.str.64, i32 %start.val)
  store i32 %calltmp, ptr %key, align 4
  %key.val = load i32, ptr %key, align 4
  %cmptmp = icmp slt i32 %key.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %key.val3 = load i32, ptr %key, align 4
  %addtmp = add i32 %key.val3, 15
  store i32 %addtmp, ptr %i, align 4
  %message.val4 = load ptr, ptr %message1, align 8
  %calltmp5 = call i32 @std__text__len(ptr %message.val4)
  store i32 %calltmp5, ptr %n, align 4
  %message.val6 = load ptr, ptr %message1, align 8
  %i.val = load i32, ptr %i, align 4
  %calltmp7 = call i32 @std__json__skip_ws(ptr %message.val6, i32 %i.val)
  store i32 %calltmp7, ptr %i, align 4
  store i32 0, ptr %value, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val10 = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp11 = icmp slt i32 %i.val10, %n.val
  %1 = zext i1 %cmptmp11 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %land.rhs8, label %land.end9

for.body:                                         ; preds = %land.end
  %value.val = load i32, ptr %value, align 4
  %multmp = mul i32 %value.val, 10
  %message.val26 = load ptr, ptr %message1, align 8
  %i.val27 = load i32, ptr %i, align 4
  %string.local.ptr28 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6429 = sext i32 %i.val27 to i64
  %string.index.ptr30 = getelementptr inbounds i8, ptr %string.local.ptr28, i64 %string.index.ptr.idx.i6429
  %string.index.load31 = load i8, ptr %string.index.ptr30, align 1
  %string.index.i3232 = zext i8 %string.index.load31 to i32
  %subtmp = sub i32 %string.index.i3232, 48
  %addtmp33 = add i32 %multmp, %subtmp
  store i32 %addtmp33, ptr %value, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %value.val34 = load i32, ptr %value, align 4
  call void @yc_frame_pop()
  ret i32 %value.val34

land.rhs:                                         ; preds = %land.end9
  %message.val16 = load ptr, ptr %message1, align 8
  %i.val17 = load i32, ptr %i, align 4
  %string.local.ptr18 = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i6419 = sext i32 %i.val17 to i64
  %string.index.ptr20 = getelementptr inbounds i8, ptr %string.local.ptr18, i64 %string.index.ptr.idx.i6419
  %string.index.load21 = load i8, ptr %string.index.ptr20, align 1
  %string.index.i3222 = zext i8 %string.index.load21 to i32
  %cmptmp23 = icmp sle i32 %string.index.i3222, 57
  %2 = zext i1 %cmptmp23 to i32
  %rhsbool24 = icmp ne i32 %2, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.end9
  %landtmp25 = phi i1 [ false, %land.end9 ], [ %rhsbool24, %land.rhs ]
  %3 = zext i1 %landtmp25 to i32
  %forcond = icmp ne i32 %3, 0
  br i1 %forcond, label %for.body, label %for.after

land.rhs8:                                        ; preds = %for.cond
  %message.val12 = load ptr, ptr %message1, align 8
  %i.val13 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %message1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val13 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp14 = icmp sge i32 %string.index.i32, 48
  %4 = zext i1 %cmptmp14 to i32
  %rhsbool = icmp ne i32 %4, 0
  br label %land.end9

land.end9:                                        ; preds = %land.rhs8, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool, %land.rhs8 ]
  %5 = zext i1 %landtmp to i32
  %lhsbool15 = icmp ne i32 %5, 0
  br i1 %lhsbool15, label %land.rhs, label %land.end
}

define i32 @std__json__digits_i32(i32 %value) {
entry:
  %value1 = alloca i32, align 4
  store i32 %value, ptr %value1, align 4
  call void @yc_frame_push()
  %value.val = load i32, ptr %value1, align 4
  %cmptmp = icmp slt i32 %value.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %value.val2 = load i32, ptr %value1, align 4
  %negtmp = sub i32 0, %value.val2
  %calltmp = call i32 @std__json__digits_i32(i32 %negtmp)
  %addtmp = add i32 %calltmp, 1
  call void @yc_frame_pop()
  ret i32 %addtmp

ifcont:                                           ; preds = %entry
  %value.val3 = load i32, ptr %value1, align 4
  %cmptmp4 = icmp slt i32 %value.val3, 10
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %ifcont7

then6:                                            ; preds = %ifcont
  call void @yc_frame_pop()
  ret i32 1

ifcont7:                                          ; preds = %ifcont
  %value.val8 = load i32, ptr %value1, align 4
  %cmptmp9 = icmp slt i32 %value.val8, 100
  %2 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %2, 0
  br i1 %ifcond10, label %then11, label %ifcont12

then11:                                           ; preds = %ifcont7
  call void @yc_frame_pop()
  ret i32 2

ifcont12:                                         ; preds = %ifcont7
  %value.val13 = load i32, ptr %value1, align 4
  %cmptmp14 = icmp slt i32 %value.val13, 1000
  %3 = zext i1 %cmptmp14 to i32
  %ifcond15 = icmp ne i32 %3, 0
  br i1 %ifcond15, label %then16, label %ifcont17

then16:                                           ; preds = %ifcont12
  call void @yc_frame_pop()
  ret i32 3

ifcont17:                                         ; preds = %ifcont12
  %value.val18 = load i32, ptr %value1, align 4
  %cmptmp19 = icmp slt i32 %value.val18, 10000
  %4 = zext i1 %cmptmp19 to i32
  %ifcond20 = icmp ne i32 %4, 0
  br i1 %ifcond20, label %then21, label %ifcont22

then21:                                           ; preds = %ifcont17
  call void @yc_frame_pop()
  ret i32 4

ifcont22:                                         ; preds = %ifcont17
  call void @yc_frame_pop()
  ret i32 5
}

define i32 @std__json__unclosed_block_comment_offset(ptr %source) {
entry:
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %start = alloca i32, align 4
  %open = alloca i1, align 1
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  store i32 0, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %subtmp = sub i32 %n.val, 1
  %cmptmp = icmp slt i32 %i.val, %subtmp
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %open.val = load i1, ptr %open, align 1
  %notcmp = icmp eq i1 %open.val, false
  %notext = zext i1 %notcmp to i32
  %lhsbool = icmp ne i32 %notext, 0
  br i1 %lhsbool, label %land.rhs2, label %land.end3

for.inc:                                          ; preds = %ifcont51
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %open.val52 = load i1, ptr %open, align 1
  %ifcond53 = icmp ne i1 %open.val52, false
  br i1 %ifcond53, label %then54, label %ifcont55

land.rhs:                                         ; preds = %land.end3
  %source.val8 = load ptr, ptr %source1, align 8
  %i.val9 = load i32, ptr %i, align 4
  %addtmp = add i32 %i.val9, 1
  %string.local.ptr10 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6411 = sext i32 %addtmp to i64
  %string.index.ptr12 = getelementptr inbounds i8, ptr %string.local.ptr10, i64 %string.index.ptr.idx.i6411
  %string.index.load13 = load i8, ptr %string.index.ptr12, align 1
  %string.index.i3214 = zext i8 %string.index.load13 to i32
  %cmptmp15 = icmp eq i32 %string.index.i3214, 42
  %1 = zext i1 %cmptmp15 to i32
  %rhsbool16 = icmp ne i32 %1, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.end3
  %landtmp17 = phi i1 [ false, %land.end3 ], [ %rhsbool16, %land.rhs ]
  %2 = zext i1 %landtmp17 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %else

land.rhs2:                                        ; preds = %for.body
  %source.val4 = load ptr, ptr %source1, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val5 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp6 = icmp eq i32 %string.index.i32, 47
  %3 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %land.end3

land.end3:                                        ; preds = %land.rhs2, %for.body
  %landtmp = phi i1 [ false, %for.body ], [ %rhsbool, %land.rhs2 ]
  %4 = zext i1 %landtmp to i32
  %lhsbool7 = icmp ne i32 %4, 0
  br i1 %lhsbool7, label %land.rhs, label %land.end

then:                                             ; preds = %land.end
  store i1 true, ptr %open, align 1
  %i.val18 = load i32, ptr %i, align 4
  store i32 %i.val18, ptr %start, align 4
  %compound.current = load i32, ptr %i, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %i, align 4
  br label %ifcont51

else:                                             ; preds = %land.end
  %open.val23 = load i1, ptr %open, align 1
  %lhsbool24 = icmp ne i1 %open.val23, false
  br i1 %lhsbool24, label %land.rhs21, label %land.end22

land.rhs19:                                       ; preds = %land.end22
  %source.val36 = load ptr, ptr %source1, align 8
  %i.val37 = load i32, ptr %i, align 4
  %addtmp38 = add i32 %i.val37, 1
  %string.local.ptr39 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6440 = sext i32 %addtmp38 to i64
  %string.index.ptr41 = getelementptr inbounds i8, ptr %string.local.ptr39, i64 %string.index.ptr.idx.i6440
  %string.index.load42 = load i8, ptr %string.index.ptr41, align 1
  %string.index.i3243 = zext i8 %string.index.load42 to i32
  %cmptmp44 = icmp eq i32 %string.index.i3243, 47
  %5 = zext i1 %cmptmp44 to i32
  %rhsbool45 = icmp ne i32 %5, 0
  br label %land.end20

land.end20:                                       ; preds = %land.rhs19, %land.end22
  %landtmp46 = phi i1 [ false, %land.end22 ], [ %rhsbool45, %land.rhs19 ]
  %6 = zext i1 %landtmp46 to i32
  %ifcond47 = icmp ne i32 %6, 0
  br i1 %ifcond47, label %then48, label %ifcont

land.rhs21:                                       ; preds = %else
  %source.val25 = load ptr, ptr %source1, align 8
  %i.val26 = load i32, ptr %i, align 4
  %string.local.ptr27 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6428 = sext i32 %i.val26 to i64
  %string.index.ptr29 = getelementptr inbounds i8, ptr %string.local.ptr27, i64 %string.index.ptr.idx.i6428
  %string.index.load30 = load i8, ptr %string.index.ptr29, align 1
  %string.index.i3231 = zext i8 %string.index.load30 to i32
  %cmptmp32 = icmp eq i32 %string.index.i3231, 42
  %7 = zext i1 %cmptmp32 to i32
  %rhsbool33 = icmp ne i32 %7, 0
  br label %land.end22

land.end22:                                       ; preds = %land.rhs21, %else
  %landtmp34 = phi i1 [ false, %else ], [ %rhsbool33, %land.rhs21 ]
  %8 = zext i1 %landtmp34 to i32
  %lhsbool35 = icmp ne i32 %8, 0
  br i1 %lhsbool35, label %land.rhs19, label %land.end20

then48:                                           ; preds = %land.end20
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  %compound.current49 = load i32, ptr %i, align 4
  %compound.add50 = add i32 %compound.current49, 1
  store i32 %compound.add50, ptr %i, align 4
  br label %ifcont

ifcont:                                           ; preds = %then48, %land.end20
  br label %ifcont51

ifcont51:                                         ; preds = %ifcont, %then
  br label %for.inc

then54:                                           ; preds = %for.after
  %start.val = load i32, ptr %start, align 4
  call void @yc_frame_pop()
  ret i32 %start.val

ifcont55:                                         ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1
}

define i32 @std__json__unclosed_string_offset(ptr %source) {
entry:
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %escape = alloca i1, align 1
  %start = alloca i32, align 4
  %open = alloca i1, align 1
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  store i1 false, ptr %escape, align 1
  store i32 0, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val2 = load ptr, ptr %source1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %escape.val = load i1, ptr %escape, align 1
  %ifcond = icmp ne i1 %escape.val, false
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont18
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %open.val19 = load i1, ptr %open, align 1
  %ifcond20 = icmp ne i1 %open.val19, false
  br i1 %ifcond20, label %then21, label %ifcont22

then:                                             ; preds = %for.body
  store i1 false, ptr %escape, align 1
  br label %ifcont18

else:                                             ; preds = %for.body
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp4 = icmp eq i32 %ch.val, 92
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %else7

then6:                                            ; preds = %else
  store i1 true, ptr %escape, align 1
  br label %ifcont17

else7:                                            ; preds = %else
  %ch.val8 = load i32, ptr %ch, align 4
  %cmptmp9 = icmp eq i32 %ch.val8, 34
  %2 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %2, 0
  br i1 %ifcond10, label %then11, label %ifcont16

then11:                                           ; preds = %else7
  %open.val = load i1, ptr %open, align 1
  %ifcond12 = icmp ne i1 %open.val, false
  br i1 %ifcond12, label %then13, label %else14

then13:                                           ; preds = %then11
  store i1 false, ptr %open, align 1
  store i32 -1, ptr %start, align 4
  br label %ifcont

else14:                                           ; preds = %then11
  store i1 true, ptr %open, align 1
  %i.val15 = load i32, ptr %i, align 4
  store i32 %i.val15, ptr %start, align 4
  br label %ifcont

ifcont:                                           ; preds = %else14, %then13
  br label %ifcont16

ifcont16:                                         ; preds = %ifcont, %else7
  br label %ifcont17

ifcont17:                                         ; preds = %ifcont16, %then6
  br label %ifcont18

ifcont18:                                         ; preds = %ifcont17, %then
  br label %for.inc

then21:                                           ; preds = %for.after
  %start.val = load i32, ptr %start, align 4
  call void @yc_frame_pop()
  ret i32 %start.val

ifcont22:                                         ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1
}

define i32 @std__json__unclosed_brace_offset(ptr %source) {
entry:
  %ch = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %escape = alloca i1, align 1
  %in_string = alloca i1, align 1
  %first_open = alloca i32, align 4
  %depth = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  store i32 0, ptr %depth, align 4
  store i32 -1, ptr %first_open, align 4
  store i1 false, ptr %in_string, align 1
  store i1 false, ptr %escape, align 1
  store i32 0, ptr %i, align 4
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val2 = load ptr, ptr %source1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val3 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  store i32 %string.index.i32, ptr %ch, align 4
  %escape.val = load i1, ptr %escape, align 1
  %ifcond = icmp ne i1 %escape.val, false
  br i1 %ifcond, label %then, label %else

for.inc:                                          ; preds = %ifcont54
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %depth.val55 = load i32, ptr %depth, align 4
  %cmptmp56 = icmp ne i32 %depth.val55, 0
  %1 = zext i1 %cmptmp56 to i32
  %ifcond57 = icmp ne i32 %1, 0
  br i1 %ifcond57, label %then58, label %ifcont59

then:                                             ; preds = %for.body
  store i1 false, ptr %escape, align 1
  br label %ifcont54

else:                                             ; preds = %for.body
  %in_string.val = load i1, ptr %in_string, align 1
  %lhsbool = icmp ne i1 %in_string.val, false
  br i1 %lhsbool, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %else
  %ch.val = load i32, ptr %ch, align 4
  %cmptmp4 = icmp eq i32 %ch.val, 92
  %2 = zext i1 %cmptmp4 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %else
  %landtmp = phi i1 [ false, %else ], [ %rhsbool, %land.rhs ]
  %3 = zext i1 %landtmp to i32
  %ifcond5 = icmp ne i32 %3, 0
  br i1 %ifcond5, label %then6, label %else7

then6:                                            ; preds = %land.end
  store i1 true, ptr %escape, align 1
  br label %ifcont53

else7:                                            ; preds = %land.end
  %ch.val8 = load i32, ptr %ch, align 4
  %cmptmp9 = icmp eq i32 %ch.val8, 34
  %4 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %4, 0
  br i1 %ifcond10, label %then11, label %else13

then11:                                           ; preds = %else7
  %in_string.val12 = load i1, ptr %in_string, align 1
  %notcmp = icmp eq i1 %in_string.val12, false
  %notext = zext i1 %notcmp to i32
  %assign_trunc = trunc i32 %notext to i1
  store i1 %assign_trunc, ptr %in_string, align 1
  br label %ifcont52

else13:                                           ; preds = %else7
  %in_string.val16 = load i1, ptr %in_string, align 1
  %notcmp17 = icmp eq i1 %in_string.val16, false
  %notext18 = zext i1 %notcmp17 to i32
  %lhsbool19 = icmp ne i32 %notext18, 0
  br i1 %lhsbool19, label %land.rhs14, label %land.end15

land.rhs14:                                       ; preds = %else13
  %ch.val20 = load i32, ptr %ch, align 4
  %cmptmp21 = icmp eq i32 %ch.val20, 123
  %5 = zext i1 %cmptmp21 to i32
  %rhsbool22 = icmp ne i32 %5, 0
  br label %land.end15

land.end15:                                       ; preds = %land.rhs14, %else13
  %landtmp23 = phi i1 [ false, %else13 ], [ %rhsbool22, %land.rhs14 ]
  %6 = zext i1 %landtmp23 to i32
  %ifcond24 = icmp ne i32 %6, 0
  br i1 %ifcond24, label %then25, label %else30

then25:                                           ; preds = %land.end15
  %depth.val = load i32, ptr %depth, align 4
  %cmptmp26 = icmp eq i32 %depth.val, 0
  %7 = zext i1 %cmptmp26 to i32
  %ifcond27 = icmp ne i32 %7, 0
  br i1 %ifcond27, label %then28, label %ifcont

then28:                                           ; preds = %then25
  %i.val29 = load i32, ptr %i, align 4
  store i32 %i.val29, ptr %first_open, align 4
  br label %ifcont

ifcont:                                           ; preds = %then28, %then25
  %compound.current = load i32, ptr %depth, align 4
  %compound.add = add i32 %compound.current, 1
  store i32 %compound.add, ptr %depth, align 4
  br label %ifcont51

else30:                                           ; preds = %land.end15
  %in_string.val33 = load i1, ptr %in_string, align 1
  %notcmp34 = icmp eq i1 %in_string.val33, false
  %notext35 = zext i1 %notcmp34 to i32
  %lhsbool36 = icmp ne i32 %notext35, 0
  br i1 %lhsbool36, label %land.rhs31, label %land.end32

land.rhs31:                                       ; preds = %else30
  %ch.val37 = load i32, ptr %ch, align 4
  %cmptmp38 = icmp eq i32 %ch.val37, 125
  %8 = zext i1 %cmptmp38 to i32
  %rhsbool39 = icmp ne i32 %8, 0
  br label %land.end32

land.end32:                                       ; preds = %land.rhs31, %else30
  %landtmp40 = phi i1 [ false, %else30 ], [ %rhsbool39, %land.rhs31 ]
  %9 = zext i1 %landtmp40 to i32
  %ifcond41 = icmp ne i32 %9, 0
  br i1 %ifcond41, label %then42, label %ifcont50

then42:                                           ; preds = %land.end32
  %depth.val43 = load i32, ptr %depth, align 4
  %cmptmp44 = icmp eq i32 %depth.val43, 0
  %10 = zext i1 %cmptmp44 to i32
  %ifcond45 = icmp ne i32 %10, 0
  br i1 %ifcond45, label %then46, label %ifcont48

then46:                                           ; preds = %then42
  %i.val47 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val47

ifcont48:                                         ; preds = %then42
  %compound.current49 = load i32, ptr %depth, align 4
  %compound.sub = sub i32 %compound.current49, 1
  store i32 %compound.sub, ptr %depth, align 4
  br label %ifcont50

ifcont50:                                         ; preds = %ifcont48, %land.end32
  br label %ifcont51

ifcont51:                                         ; preds = %ifcont50, %ifcont
  br label %ifcont52

ifcont52:                                         ; preds = %ifcont51, %then11
  br label %ifcont53

ifcont53:                                         ; preds = %ifcont52, %then6
  br label %ifcont54

ifcont54:                                         ; preds = %ifcont53, %then
  br label %for.inc

then58:                                           ; preds = %for.after
  %first_open.val = load i32, ptr %first_open, align 4
  call void @yc_frame_pop()
  ret i32 %first_open.val

ifcont59:                                         ; preds = %for.after
  call void @yc_frame_pop()
  ret i32 -1
}

define internal i1 @std__json__looks_like_ident_start(i32 %ch) {
entry:
  %ch1 = alloca i32, align 4
  store i32 %ch, ptr %ch1, align 4
  call void @yc_frame_push()
  %ch.val = load i32, ptr %ch1, align 4
  %cmptmp = icmp sge i32 %ch.val, 97
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

lor.rhs:                                          ; preds = %lor.end3
  %ch.val18 = load i32, ptr %ch1, align 4
  %cmptmp19 = icmp eq i32 %ch.val18, 95
  %1 = zext i1 %cmptmp19 to i32
  %rhsbool20 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end3
  %lortmp21 = phi i1 [ true, %lor.end3 ], [ %rhsbool20, %lor.rhs ]
  %2 = zext i1 %lortmp21 to i32
  %return.intcast = trunc i32 %2 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast

lor.rhs2:                                         ; preds = %land.end
  %ch.val9 = load i32, ptr %ch1, align 4
  %cmptmp10 = icmp sge i32 %ch.val9, 65
  %3 = zext i1 %cmptmp10 to i32
  %lhsbool11 = icmp ne i32 %3, 0
  br i1 %lhsbool11, label %land.rhs7, label %land.end8

lor.end3:                                         ; preds = %land.end8, %land.end
  %lortmp = phi i1 [ true, %land.end ], [ %rhsbool16, %land.end8 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool17 = icmp ne i32 %4, 0
  br i1 %lhsbool17, label %lor.end, label %lor.rhs

land.rhs:                                         ; preds = %entry
  %ch.val4 = load i32, ptr %ch1, align 4
  %cmptmp5 = icmp sle i32 %ch.val4, 122
  %5 = zext i1 %cmptmp5 to i32
  %rhsbool = icmp ne i32 %5, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %landtmp = phi i1 [ false, %entry ], [ %rhsbool, %land.rhs ]
  %6 = zext i1 %landtmp to i32
  %lhsbool6 = icmp ne i32 %6, 0
  br i1 %lhsbool6, label %lor.end3, label %lor.rhs2

land.rhs7:                                        ; preds = %lor.rhs2
  %ch.val12 = load i32, ptr %ch1, align 4
  %cmptmp13 = icmp sle i32 %ch.val12, 90
  %7 = zext i1 %cmptmp13 to i32
  %rhsbool14 = icmp ne i32 %7, 0
  br label %land.end8

land.end8:                                        ; preds = %land.rhs7, %lor.rhs2
  %landtmp15 = phi i1 [ false, %lor.rhs2 ], [ %rhsbool14, %land.rhs7 ]
  %8 = zext i1 %landtmp15 to i32
  %rhsbool16 = icmp ne i32 %8, 0
  br label %lor.end3
}

define internal i1 @std__json__has_word_before(ptr %source, i32 %pos, ptr %word) {
entry:
  %start = alloca i32, align 4
  %i = alloca i32, align 4
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %pos2 = alloca i32, align 4
  store i32 %pos, ptr %pos2, align 4
  %word3 = alloca ptr, align 8
  store ptr %word, ptr %word3, align 8
  call void @yc_frame_push()
  %word.val = load ptr, ptr %word3, align 8
  %calltmp = call i32 @std__text__len(ptr %word.val)
  store i32 %calltmp, ptr %n, align 4
  %pos.val = load i32, ptr %pos2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %pos.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  %pos.val4 = load i32, ptr %pos2, align 4
  %n.val5 = load i32, ptr %n, align 4
  %subtmp = sub i32 %pos.val4, %n.val5
  store i32 %subtmp, ptr %start, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %n.val6 = load i32, ptr %n, align 4
  %cmptmp7 = icmp slt i32 %i.val, %n.val6
  %1 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %source.val = load ptr, ptr %source1, align 8
  %start.val = load i32, ptr %start, align 4
  %i.val8 = load i32, ptr %i, align 4
  %addtmp = add i32 %start.val, %i.val8
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %addtmp to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %word.val9 = load ptr, ptr %word3, align 8
  %i.val10 = load i32, ptr %i, align 4
  %string.local.ptr11 = load ptr, ptr %word3, align 8
  %string.index.ptr.idx.i6412 = sext i32 %i.val10 to i64
  %string.index.ptr13 = getelementptr inbounds i8, ptr %string.local.ptr11, i64 %string.index.ptr.idx.i6412
  %string.index.load14 = load i8, ptr %string.index.ptr13, align 1
  %string.index.i3215 = zext i8 %string.index.load14 to i32
  %cmptmp16 = icmp ne i32 %string.index.i32, %string.index.i3215
  %2 = zext i1 %cmptmp16 to i32
  %ifcond17 = icmp ne i32 %2, 0
  br i1 %ifcond17, label %then18, label %ifcont19

for.inc:                                          ; preds = %ifcont19
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then18:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont19:                                         ; preds = %for.body
  br label %for.inc
}

define internal i32 @std__json__skip_inline_ws(ptr %source, i32 %i) {
entry:
  %n = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %i2 = alloca i32, align 4
  store i32 %i, ptr %i2, align 4
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__len(ptr %source.val)
  store i32 %calltmp, ptr %n, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i2, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %land.rhs, label %land.end

for.body:                                         ; preds = %land.end
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i2, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i2, align 4
  br label %for.cond

for.after:                                        ; preds = %land.end
  %i.val16 = load i32, ptr %i2, align 4
  call void @yc_frame_pop()
  ret i32 %i.val16

land.rhs:                                         ; preds = %for.cond
  %source.val3 = load ptr, ptr %source1, align 8
  %i.val4 = load i32, ptr %i2, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val4 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp5 = icmp eq i32 %string.index.i32, 32
  %1 = zext i1 %cmptmp5 to i32
  %lhsbool6 = icmp ne i32 %1, 0
  br i1 %lhsbool6, label %lor.end, label %lor.rhs

land.end:                                         ; preds = %lor.end, %for.cond
  %landtmp = phi i1 [ false, %for.cond ], [ %rhsbool15, %lor.end ]
  %2 = zext i1 %landtmp to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

lor.rhs:                                          ; preds = %land.rhs
  %source.val7 = load ptr, ptr %source1, align 8
  %i.val8 = load i32, ptr %i2, align 4
  %string.local.ptr9 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6410 = sext i32 %i.val8 to i64
  %string.index.ptr11 = getelementptr inbounds i8, ptr %string.local.ptr9, i64 %string.index.ptr.idx.i6410
  %string.index.load12 = load i8, ptr %string.index.ptr11, align 1
  %string.index.i3213 = zext i8 %string.index.load12 to i32
  %cmptmp14 = icmp eq i32 %string.index.i3213, 9
  %3 = zext i1 %cmptmp14 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %land.rhs
  %lortmp = phi i1 [ true, %land.rhs ], [ %rhsbool, %lor.rhs ]
  %4 = zext i1 %lortmp to i32
  %rhsbool15 = icmp ne i32 %4, 0
  br label %land.end
}

define i32 @std__json__malformed_import_offset(ptr %source) {
entry:
  %alias_start = alloca i32, align 4
  %after = alloca i32, align 4
  %end_pos = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %pos = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__find(ptr %source.val, ptr @.str.65)
  store i32 %calltmp, ptr %pos, align 4
  %pos.val = load i32, ptr %pos, align 4
  %cmptmp = icmp slt i32 %pos.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %pos.val3 = load i32, ptr %pos, align 4
  %addtmp = add i32 %pos.val3, 7
  %calltmp4 = call i32 @std__json__skip_ws(ptr %source.val2, i32 %addtmp)
  store i32 %calltmp4, ptr %i, align 4
  %source.val5 = load ptr, ptr %source1, align 8
  %calltmp6 = call i32 @std__text__len(ptr %source.val5)
  store i32 %calltmp6, ptr %n, align 4
  %i.val = load i32, ptr %i, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp7 = icmp sge i32 %i.val, %n.val
  %1 = zext i1 %cmptmp7 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont
  %source.val8 = load ptr, ptr %source1, align 8
  %i.val9 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val9 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp10 = icmp ne i32 %string.index.i32, 34
  %2 = zext i1 %cmptmp10 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont
  %lortmp = phi i1 [ true, %ifcont ], [ %rhsbool, %lor.rhs ]
  %3 = zext i1 %lortmp to i32
  %ifcond11 = icmp ne i32 %3, 0
  br i1 %ifcond11, label %then12, label %ifcont14

then12:                                           ; preds = %lor.end
  %pos.val13 = load i32, ptr %pos, align 4
  call void @yc_frame_pop()
  ret i32 %pos.val13

ifcont14:                                         ; preds = %lor.end
  %source.val15 = load ptr, ptr %source1, align 8
  %i.val16 = load i32, ptr %i, align 4
  %calltmp17 = call i32 @std__json__string_end(ptr %source.val15, i32 %i.val16)
  store i32 %calltmp17, ptr %end_pos, align 4
  %end_pos.val = load i32, ptr %end_pos, align 4
  %cmptmp18 = icmp slt i32 %end_pos.val, 0
  %4 = zext i1 %cmptmp18 to i32
  %ifcond19 = icmp ne i32 %4, 0
  br i1 %ifcond19, label %then20, label %ifcont22

then20:                                           ; preds = %ifcont14
  %i.val21 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val21

ifcont22:                                         ; preds = %ifcont14
  %source.val23 = load ptr, ptr %source1, align 8
  %end_pos.val24 = load i32, ptr %end_pos, align 4
  %addtmp25 = add i32 %end_pos.val24, 1
  %calltmp26 = call i32 @std__json__skip_ws(ptr %source.val23, i32 %addtmp25)
  store i32 %calltmp26, ptr %after, align 4
  %after.val = load i32, ptr %after, align 4
  %n.val27 = load i32, ptr %n, align 4
  %cmptmp28 = icmp slt i32 %after.val, %n.val27
  %5 = zext i1 %cmptmp28 to i32
  %lhsbool29 = icmp ne i32 %5, 0
  br i1 %lhsbool29, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %ifcont22
  %source.val30 = load ptr, ptr %source1, align 8
  %after.val31 = load i32, ptr %after, align 4
  %string.local.ptr32 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6433 = sext i32 %after.val31 to i64
  %string.index.ptr34 = getelementptr inbounds i8, ptr %string.local.ptr32, i64 %string.index.ptr.idx.i6433
  %string.index.load35 = load i8, ptr %string.index.ptr34, align 1
  %string.index.i3236 = zext i8 %string.index.load35 to i32
  %cmptmp37 = icmp eq i32 %string.index.i3236, 97
  %6 = zext i1 %cmptmp37 to i32
  %rhsbool38 = icmp ne i32 %6, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %ifcont22
  %landtmp = phi i1 [ false, %ifcont22 ], [ %rhsbool38, %land.rhs ]
  %7 = zext i1 %landtmp to i32
  %ifcond39 = icmp ne i32 %7, 0
  br i1 %ifcond39, label %then40, label %ifcont86

then40:                                           ; preds = %land.end
  %after.val43 = load i32, ptr %after, align 4
  %addtmp44 = add i32 %after.val43, 1
  %n.val45 = load i32, ptr %n, align 4
  %cmptmp46 = icmp sge i32 %addtmp44, %n.val45
  %8 = zext i1 %cmptmp46 to i32
  %lhsbool47 = icmp ne i32 %8, 0
  br i1 %lhsbool47, label %lor.end42, label %lor.rhs41

lor.rhs41:                                        ; preds = %then40
  %source.val48 = load ptr, ptr %source1, align 8
  %after.val49 = load i32, ptr %after, align 4
  %addtmp50 = add i32 %after.val49, 1
  %string.local.ptr51 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6452 = sext i32 %addtmp50 to i64
  %string.index.ptr53 = getelementptr inbounds i8, ptr %string.local.ptr51, i64 %string.index.ptr.idx.i6452
  %string.index.load54 = load i8, ptr %string.index.ptr53, align 1
  %string.index.i3255 = zext i8 %string.index.load54 to i32
  %cmptmp56 = icmp ne i32 %string.index.i3255, 115
  %9 = zext i1 %cmptmp56 to i32
  %rhsbool57 = icmp ne i32 %9, 0
  br label %lor.end42

lor.end42:                                        ; preds = %lor.rhs41, %then40
  %lortmp58 = phi i1 [ true, %then40 ], [ %rhsbool57, %lor.rhs41 ]
  %10 = zext i1 %lortmp58 to i32
  %ifcond59 = icmp ne i32 %10, 0
  br i1 %ifcond59, label %then60, label %ifcont62

then60:                                           ; preds = %lor.end42
  %after.val61 = load i32, ptr %after, align 4
  call void @yc_frame_pop()
  ret i32 %after.val61

ifcont62:                                         ; preds = %lor.end42
  %source.val63 = load ptr, ptr %source1, align 8
  %after.val64 = load i32, ptr %after, align 4
  %addtmp65 = add i32 %after.val64, 2
  %calltmp66 = call i32 @std__json__skip_inline_ws(ptr %source.val63, i32 %addtmp65)
  store i32 %calltmp66, ptr %alias_start, align 4
  %alias_start.val = load i32, ptr %alias_start, align 4
  %n.val69 = load i32, ptr %n, align 4
  %cmptmp70 = icmp sge i32 %alias_start.val, %n.val69
  %11 = zext i1 %cmptmp70 to i32
  %lhsbool71 = icmp ne i32 %11, 0
  br i1 %lhsbool71, label %lor.end68, label %lor.rhs67

lor.rhs67:                                        ; preds = %ifcont62
  %source.val72 = load ptr, ptr %source1, align 8
  %alias_start.val73 = load i32, ptr %alias_start, align 4
  %string.local.ptr74 = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i6475 = sext i32 %alias_start.val73 to i64
  %string.index.ptr76 = getelementptr inbounds i8, ptr %string.local.ptr74, i64 %string.index.ptr.idx.i6475
  %string.index.load77 = load i8, ptr %string.index.ptr76, align 1
  %string.index.i3278 = zext i8 %string.index.load77 to i32
  %calltmp79 = call i1 @std__json__looks_like_ident_start(i32 %string.index.i3278)
  %notcmp = icmp eq i1 %calltmp79, false
  %notext = zext i1 %notcmp to i32
  %rhsbool80 = icmp ne i32 %notext, 0
  br label %lor.end68

lor.end68:                                        ; preds = %lor.rhs67, %ifcont62
  %lortmp81 = phi i1 [ true, %ifcont62 ], [ %rhsbool80, %lor.rhs67 ]
  %12 = zext i1 %lortmp81 to i32
  %ifcond82 = icmp ne i32 %12, 0
  br i1 %ifcond82, label %then83, label %ifcont85

then83:                                           ; preds = %lor.end68
  %after.val84 = load i32, ptr %after, align 4
  call void @yc_frame_pop()
  ret i32 %after.val84

ifcont85:                                         ; preds = %lor.end68
  br label %ifcont86

ifcont86:                                         ; preds = %ifcont85, %land.end
  call void @yc_frame_pop()
  ret i32 -1
}

define i32 @std__json__malformed_function_offset(ptr %source) {
entry:
  %block = alloca i32, align 4
  %close_paren = alloca i32, align 4
  %open_paren = alloca i32, align 4
  %n = alloca i32, align 4
  %name_start = alloca i32, align 4
  %pos = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__text__find(ptr %source.val, ptr @.str.66)
  store i32 %calltmp, ptr %pos, align 4
  %pos.val = load i32, ptr %pos, align 4
  %cmptmp = icmp slt i32 %pos.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 -1

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %pos.val3 = load i32, ptr %pos, align 4
  %calltmp4 = call i1 @std__json__has_word_before(ptr %source.val2, i32 %pos.val3, ptr @.str.67)
  %lhsbool = icmp ne i1 %calltmp4, false
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont
  %source.val5 = load ptr, ptr %source1, align 8
  %pos.val6 = load i32, ptr %pos, align 4
  %calltmp7 = call i1 @std__json__has_word_before(ptr %source.val5, i32 %pos.val6, ptr @.str.68)
  %rhsbool = icmp ne i1 %calltmp7, false
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont
  %lortmp = phi i1 [ true, %ifcont ], [ %rhsbool, %lor.rhs ]
  %1 = zext i1 %lortmp to i32
  %ifcond8 = icmp ne i32 %1, 0
  br i1 %ifcond8, label %then9, label %ifcont10

then9:                                            ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 -1

ifcont10:                                         ; preds = %lor.end
  %source.val11 = load ptr, ptr %source1, align 8
  %pos.val12 = load i32, ptr %pos, align 4
  %addtmp = add i32 %pos.val12, 3
  %calltmp13 = call i32 @std__json__skip_ws(ptr %source.val11, i32 %addtmp)
  store i32 %calltmp13, ptr %name_start, align 4
  %source.val14 = load ptr, ptr %source1, align 8
  %calltmp15 = call i32 @std__text__len(ptr %source.val14)
  store i32 %calltmp15, ptr %n, align 4
  %name_start.val = load i32, ptr %name_start, align 4
  %n.val = load i32, ptr %n, align 4
  %cmptmp18 = icmp sge i32 %name_start.val, %n.val
  %2 = zext i1 %cmptmp18 to i32
  %lhsbool19 = icmp ne i32 %2, 0
  br i1 %lhsbool19, label %lor.end17, label %lor.rhs16

lor.rhs16:                                        ; preds = %ifcont10
  %source.val20 = load ptr, ptr %source1, align 8
  %name_start.val21 = load i32, ptr %name_start, align 4
  %string.local.ptr = load ptr, ptr %source1, align 8
  %string.index.ptr.idx.i64 = sext i32 %name_start.val21 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %calltmp22 = call i1 @std__json__looks_like_ident_start(i32 %string.index.i32)
  %notcmp = icmp eq i1 %calltmp22, false
  %notext = zext i1 %notcmp to i32
  %rhsbool23 = icmp ne i32 %notext, 0
  br label %lor.end17

lor.end17:                                        ; preds = %lor.rhs16, %ifcont10
  %lortmp24 = phi i1 [ true, %ifcont10 ], [ %rhsbool23, %lor.rhs16 ]
  %3 = zext i1 %lortmp24 to i32
  %ifcond25 = icmp ne i32 %3, 0
  br i1 %ifcond25, label %then26, label %ifcont28

then26:                                           ; preds = %lor.end17
  %pos.val27 = load i32, ptr %pos, align 4
  call void @yc_frame_pop()
  ret i32 %pos.val27

ifcont28:                                         ; preds = %lor.end17
  %source.val29 = load ptr, ptr %source1, align 8
  %name_start.val30 = load i32, ptr %name_start, align 4
  %calltmp31 = call i32 @std__text__find_from(ptr %source.val29, ptr @.str.69, i32 %name_start.val30)
  store i32 %calltmp31, ptr %open_paren, align 4
  %open_paren.val = load i32, ptr %open_paren, align 4
  %cmptmp32 = icmp slt i32 %open_paren.val, 0
  %4 = zext i1 %cmptmp32 to i32
  %ifcond33 = icmp ne i32 %4, 0
  br i1 %ifcond33, label %then34, label %ifcont36

then34:                                           ; preds = %ifcont28
  %pos.val35 = load i32, ptr %pos, align 4
  call void @yc_frame_pop()
  ret i32 %pos.val35

ifcont36:                                         ; preds = %ifcont28
  %source.val37 = load ptr, ptr %source1, align 8
  %open_paren.val38 = load i32, ptr %open_paren, align 4
  %calltmp39 = call i32 @std__text__find_from(ptr %source.val37, ptr @.str.70, i32 %open_paren.val38)
  store i32 %calltmp39, ptr %close_paren, align 4
  %close_paren.val = load i32, ptr %close_paren, align 4
  %cmptmp40 = icmp slt i32 %close_paren.val, 0
  %5 = zext i1 %cmptmp40 to i32
  %ifcond41 = icmp ne i32 %5, 0
  br i1 %ifcond41, label %then42, label %ifcont44

then42:                                           ; preds = %ifcont36
  %open_paren.val43 = load i32, ptr %open_paren, align 4
  call void @yc_frame_pop()
  ret i32 %open_paren.val43

ifcont44:                                         ; preds = %ifcont36
  %source.val45 = load ptr, ptr %source1, align 8
  %close_paren.val46 = load i32, ptr %close_paren, align 4
  %calltmp47 = call i32 @std__text__find_from(ptr %source.val45, ptr @.str.71, i32 %close_paren.val46)
  store i32 %calltmp47, ptr %block, align 4
  %block.val = load i32, ptr %block, align 4
  %cmptmp48 = icmp slt i32 %block.val, 0
  %6 = zext i1 %cmptmp48 to i32
  %ifcond49 = icmp ne i32 %6, 0
  br i1 %ifcond49, label %then50, label %ifcont52

then50:                                           ; preds = %ifcont44
  %close_paren.val51 = load i32, ptr %close_paren, align 4
  call void @yc_frame_pop()
  ret i32 %close_paren.val51

ifcont52:                                         ; preds = %ifcont44
  call void @yc_frame_pop()
  ret i32 -1
}

define i1 @std__json__has_unclosed_brace(ptr %source) {
entry:
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__json__unclosed_brace_offset(ptr %source.val)
  %cmptmp = icmp sge i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define i1 @std__json__has_unclosed_string(ptr %source) {
entry:
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__json__unclosed_string_offset(ptr %source.val)
  %cmptmp = icmp sge i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define i32 @std__json__syntax_error_kind(ptr %source) {
entry:
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  call void @yc_frame_push()
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__json__unclosed_block_comment_offset(ptr %source.val)
  %cmptmp = icmp sge i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 1

ifcont:                                           ; preds = %entry
  %source.val2 = load ptr, ptr %source1, align 8
  %calltmp3 = call i32 @std__json__unclosed_string_offset(ptr %source.val2)
  %cmptmp4 = icmp sge i32 %calltmp3, 0
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %ifcont7

then6:                                            ; preds = %ifcont
  call void @yc_frame_pop()
  ret i32 2

ifcont7:                                          ; preds = %ifcont
  %source.val8 = load ptr, ptr %source1, align 8
  %calltmp9 = call i32 @std__json__unclosed_brace_offset(ptr %source.val8)
  %cmptmp10 = icmp sge i32 %calltmp9, 0
  %2 = zext i1 %cmptmp10 to i32
  %ifcond11 = icmp ne i32 %2, 0
  br i1 %ifcond11, label %then12, label %ifcont13

then12:                                           ; preds = %ifcont7
  call void @yc_frame_pop()
  ret i32 3

ifcont13:                                         ; preds = %ifcont7
  %source.val18 = load ptr, ptr %source1, align 8
  %calltmp19 = call i1 @std__text__starts_with(ptr %source.val18, ptr @.str.72)
  %lhsbool = icmp ne i1 %calltmp19, false
  br i1 %lhsbool, label %lor.end17, label %lor.rhs16

lor.rhs:                                          ; preds = %lor.end15
  %source.val28 = load ptr, ptr %source1, align 8
  %calltmp29 = call i1 @std__text__contains(ptr %source.val28, ptr @.str.75)
  %rhsbool30 = icmp ne i1 %calltmp29, false
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end15
  %lortmp31 = phi i1 [ true, %lor.end15 ], [ %rhsbool30, %lor.rhs ]
  %3 = zext i1 %lortmp31 to i32
  %ifcond32 = icmp ne i32 %3, 0
  br i1 %ifcond32, label %then33, label %ifcont34

lor.rhs14:                                        ; preds = %lor.end17
  %source.val23 = load ptr, ptr %source1, align 8
  %calltmp24 = call i1 @std__text__contains(ptr %source.val23, ptr @.str.74)
  %rhsbool25 = icmp ne i1 %calltmp24, false
  br label %lor.end15

lor.end15:                                        ; preds = %lor.rhs14, %lor.end17
  %lortmp26 = phi i1 [ true, %lor.end17 ], [ %rhsbool25, %lor.rhs14 ]
  %4 = zext i1 %lortmp26 to i32
  %lhsbool27 = icmp ne i32 %4, 0
  br i1 %lhsbool27, label %lor.end, label %lor.rhs

lor.rhs16:                                        ; preds = %ifcont13
  %source.val20 = load ptr, ptr %source1, align 8
  %calltmp21 = call i1 @std__text__starts_with(ptr %source.val20, ptr @.str.73)
  %rhsbool = icmp ne i1 %calltmp21, false
  br label %lor.end17

lor.end17:                                        ; preds = %lor.rhs16, %ifcont13
  %lortmp = phi i1 [ true, %ifcont13 ], [ %rhsbool, %lor.rhs16 ]
  %5 = zext i1 %lortmp to i32
  %lhsbool22 = icmp ne i32 %5, 0
  br i1 %lhsbool22, label %lor.end15, label %lor.rhs14

then33:                                           ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 4

ifcont34:                                         ; preds = %lor.end
  %source.val35 = load ptr, ptr %source1, align 8
  %calltmp36 = call i32 @std__json__malformed_import_offset(ptr %source.val35)
  %cmptmp37 = icmp sge i32 %calltmp36, 0
  %6 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %6, 0
  br i1 %ifcond38, label %then39, label %ifcont40

then39:                                           ; preds = %ifcont34
  call void @yc_frame_pop()
  ret i32 5

ifcont40:                                         ; preds = %ifcont34
  %source.val41 = load ptr, ptr %source1, align 8
  %calltmp42 = call i32 @std__json__malformed_function_offset(ptr %source.val41)
  %cmptmp43 = icmp sge i32 %calltmp42, 0
  %7 = zext i1 %cmptmp43 to i32
  %ifcond44 = icmp ne i32 %7, 0
  br i1 %ifcond44, label %then45, label %ifcont46

then45:                                           ; preds = %ifcont40
  call void @yc_frame_pop()
  ret i32 6

ifcont46:                                         ; preds = %ifcont40
  call void @yc_frame_pop()
  ret i32 0
}

define i32 @std__json__syntax_error_offset(ptr %source, i32 %kind) {
entry:
  %direct = alloca i32, align 4
  %source1 = alloca ptr, align 8
  store ptr %source, ptr %source1, align 8
  %kind2 = alloca i32, align 4
  store i32 %kind, ptr %kind2, align 4
  call void @yc_frame_push()
  %kind.val = load i32, ptr %kind2, align 4
  %cmptmp = icmp eq i32 %kind.val, 1
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %source.val = load ptr, ptr %source1, align 8
  %calltmp = call i32 @std__json__unclosed_block_comment_offset(ptr %source.val)
  call void @yc_frame_pop()
  ret i32 %calltmp

ifcont:                                           ; preds = %entry
  %kind.val3 = load i32, ptr %kind2, align 4
  %cmptmp4 = icmp eq i32 %kind.val3, 2
  %1 = zext i1 %cmptmp4 to i32
  %ifcond5 = icmp ne i32 %1, 0
  br i1 %ifcond5, label %then6, label %ifcont9

then6:                                            ; preds = %ifcont
  %source.val7 = load ptr, ptr %source1, align 8
  %calltmp8 = call i32 @std__json__unclosed_string_offset(ptr %source.val7)
  call void @yc_frame_pop()
  ret i32 %calltmp8

ifcont9:                                          ; preds = %ifcont
  %kind.val10 = load i32, ptr %kind2, align 4
  %cmptmp11 = icmp eq i32 %kind.val10, 3
  %2 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %2, 0
  br i1 %ifcond12, label %then13, label %ifcont16

then13:                                           ; preds = %ifcont9
  %source.val14 = load ptr, ptr %source1, align 8
  %calltmp15 = call i32 @std__json__unclosed_brace_offset(ptr %source.val14)
  call void @yc_frame_pop()
  ret i32 %calltmp15

ifcont16:                                         ; preds = %ifcont9
  %source.val17 = load ptr, ptr %source1, align 8
  %calltmp18 = call i1 @std__text__starts_with(ptr %source.val17, ptr @.str.76)
  %lhsbool = icmp ne i1 %calltmp18, false
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont16
  %source.val19 = load ptr, ptr %source1, align 8
  %calltmp20 = call i1 @std__text__starts_with(ptr %source.val19, ptr @.str.77)
  %rhsbool = icmp ne i1 %calltmp20, false
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont16
  %lortmp = phi i1 [ true, %ifcont16 ], [ %rhsbool, %lor.rhs ]
  %3 = zext i1 %lortmp to i32
  %ifcond21 = icmp ne i32 %3, 0
  br i1 %ifcond21, label %then22, label %ifcont23

then22:                                           ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 0

ifcont23:                                         ; preds = %lor.end
  %source.val24 = load ptr, ptr %source1, align 8
  %calltmp25 = call i32 @std__text__find(ptr %source.val24, ptr @.str.78)
  store i32 %calltmp25, ptr %direct, align 4
  %direct.val = load i32, ptr %direct, align 4
  %cmptmp26 = icmp sge i32 %direct.val, 0
  %4 = zext i1 %cmptmp26 to i32
  %ifcond27 = icmp ne i32 %4, 0
  br i1 %ifcond27, label %then28, label %ifcont30

then28:                                           ; preds = %ifcont23
  %direct.val29 = load i32, ptr %direct, align 4
  %addtmp = add i32 %direct.val29, 1
  call void @yc_frame_pop()
  ret i32 %addtmp

ifcont30:                                         ; preds = %ifcont23
  %source.val31 = load ptr, ptr %source1, align 8
  %calltmp32 = call i32 @std__text__find(ptr %source.val31, ptr @.str.79)
  store i32 %calltmp32, ptr %direct, align 4
  %direct.val33 = load i32, ptr %direct, align 4
  %cmptmp34 = icmp sge i32 %direct.val33, 0
  %5 = zext i1 %cmptmp34 to i32
  %ifcond35 = icmp ne i32 %5, 0
  br i1 %ifcond35, label %then36, label %ifcont39

then36:                                           ; preds = %ifcont30
  %direct.val37 = load i32, ptr %direct, align 4
  %addtmp38 = add i32 %direct.val37, 1
  call void @yc_frame_pop()
  ret i32 %addtmp38

ifcont39:                                         ; preds = %ifcont30
  %kind.val40 = load i32, ptr %kind2, align 4
  %cmptmp41 = icmp eq i32 %kind.val40, 5
  %6 = zext i1 %cmptmp41 to i32
  %ifcond42 = icmp ne i32 %6, 0
  br i1 %ifcond42, label %then43, label %ifcont46

then43:                                           ; preds = %ifcont39
  %source.val44 = load ptr, ptr %source1, align 8
  %calltmp45 = call i32 @std__json__malformed_import_offset(ptr %source.val44)
  call void @yc_frame_pop()
  ret i32 %calltmp45

ifcont46:                                         ; preds = %ifcont39
  %kind.val47 = load i32, ptr %kind2, align 4
  %cmptmp48 = icmp eq i32 %kind.val47, 6
  %7 = zext i1 %cmptmp48 to i32
  %ifcond49 = icmp ne i32 %7, 0
  br i1 %ifcond49, label %then50, label %ifcont53

then50:                                           ; preds = %ifcont46
  %source.val51 = load ptr, ptr %source1, align 8
  %calltmp52 = call i32 @std__json__malformed_function_offset(ptr %source.val51)
  call void @yc_frame_pop()
  ret i32 %calltmp52

ifcont53:                                         ; preds = %ifcont46
  call void @yc_frame_pop()
  ret i32 0
}

define ptr @std__json__syntax_error_message(i32 %kind) {
entry:
  %kind1 = alloca i32, align 4
  store i32 %kind, ptr %kind1, align 4
  call void @yc_frame_push()
  %kind.val = load i32, ptr %kind1, align 4
  %cmptmp = icmp eq i32 %kind.val, 1
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr @.str.80)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %kind.val2 = load i32, ptr %kind1, align 4
  %cmptmp3 = icmp eq i32 %kind.val2, 2
  %1 = zext i1 %cmptmp3 to i32
  %ifcond4 = icmp ne i32 %1, 0
  br i1 %ifcond4, label %then5, label %ifcont7

then5:                                            ; preds = %ifcont
  %runtime.move6 = call ptr @yc_move_to_parent(ptr @.str.81)
  call void @yc_frame_pop()
  ret ptr %runtime.move6

ifcont7:                                          ; preds = %ifcont
  %kind.val8 = load i32, ptr %kind1, align 4
  %cmptmp9 = icmp eq i32 %kind.val8, 3
  %2 = zext i1 %cmptmp9 to i32
  %ifcond10 = icmp ne i32 %2, 0
  br i1 %ifcond10, label %then11, label %ifcont13

then11:                                           ; preds = %ifcont7
  %runtime.move12 = call ptr @yc_move_to_parent(ptr @.str.82)
  call void @yc_frame_pop()
  ret ptr %runtime.move12

ifcont13:                                         ; preds = %ifcont7
  %kind.val14 = load i32, ptr %kind1, align 4
  %cmptmp15 = icmp eq i32 %kind.val14, 4
  %3 = zext i1 %cmptmp15 to i32
  %ifcond16 = icmp ne i32 %3, 0
  br i1 %ifcond16, label %then17, label %ifcont19

then17:                                           ; preds = %ifcont13
  %runtime.move18 = call ptr @yc_move_to_parent(ptr @.str.83)
  call void @yc_frame_pop()
  ret ptr %runtime.move18

ifcont19:                                         ; preds = %ifcont13
  %kind.val20 = load i32, ptr %kind1, align 4
  %cmptmp21 = icmp eq i32 %kind.val20, 5
  %4 = zext i1 %cmptmp21 to i32
  %ifcond22 = icmp ne i32 %4, 0
  br i1 %ifcond22, label %then23, label %ifcont25

then23:                                           ; preds = %ifcont19
  %runtime.move24 = call ptr @yc_move_to_parent(ptr @.str.84)
  call void @yc_frame_pop()
  ret ptr %runtime.move24

ifcont25:                                         ; preds = %ifcont19
  %kind.val26 = load i32, ptr %kind1, align 4
  %cmptmp27 = icmp eq i32 %kind.val26, 6
  %5 = zext i1 %cmptmp27 to i32
  %ifcond28 = icmp ne i32 %5, 0
  br i1 %ifcond28, label %then29, label %ifcont31

then29:                                           ; preds = %ifcont25
  %runtime.move30 = call ptr @yc_move_to_parent(ptr @.str.85)
  call void @yc_frame_pop()
  ret ptr %runtime.move30

ifcont31:                                         ; preds = %ifcont25
  %runtime.move32 = call ptr @yc_move_to_parent(ptr @.str.86)
  call void @yc_frame_pop()
  ret ptr %runtime.move32
}

define ptr @std__mem__alloc(i64 %size) {
entry:
  %size1 = alloca i64, align 8
  store i64 %size, ptr %size1, align 4
  call void @yc_frame_push()
  %size.val = load i64, ptr %size1, align 4
  %calltmp = call ptr @yc_alloc(i64 %size.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define ptr @std__mem__calloc(i64 %count, i64 %size) {
entry:
  %count1 = alloca i64, align 8
  store i64 %count, ptr %count1, align 4
  %size2 = alloca i64, align 8
  store i64 %size, ptr %size2, align 4
  call void @yc_frame_push()
  %count.val = load i64, ptr %count1, align 4
  %size.val = load i64, ptr %size2, align 4
  %calltmp = call ptr @yc_calloc(i64 %count.val, i64 %size.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define ptr @std__mem__realloc(ptr %ptr, i64 %size) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  %size2 = alloca i64, align 8
  store i64 %size, ptr %size2, align 4
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  %size.val = load i64, ptr %size2, align 4
  %calltmp = call ptr @yc_realloc(ptr %ptr.val, i64 %size.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std__mem__free(ptr %ptr) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  call void @yc_release(ptr %ptr.val)
  call void @yc_frame_pop()
  ret void
}

define void @std__mem__attach_child(ptr %parent, ptr %child) {
entry:
  %parent1 = alloca ptr, align 8
  store ptr %parent, ptr %parent1, align 8
  %child2 = alloca ptr, align 8
  store ptr %child, ptr %child2, align 8
  call void @yc_frame_push()
  %parent.val = load ptr, ptr %parent1, align 8
  %child.val = load ptr, ptr %child2, align 8
  call void @yc_attach_child(ptr %parent.val, ptr %child.val)
  call void @yc_frame_pop()
  ret void
}

define void @std__mem__replace_child(ptr %parent, ptr %old_child, ptr %new_child) {
entry:
  %parent1 = alloca ptr, align 8
  store ptr %parent, ptr %parent1, align 8
  %old_child2 = alloca ptr, align 8
  store ptr %old_child, ptr %old_child2, align 8
  %new_child3 = alloca ptr, align 8
  store ptr %new_child, ptr %new_child3, align 8
  call void @yc_frame_push()
  %parent.val = load ptr, ptr %parent1, align 8
  %old_child.val = load ptr, ptr %old_child2, align 8
  %new_child.val = load ptr, ptr %new_child3, align 8
  call void @yc_replace_child(ptr %parent.val, ptr %old_child.val, ptr %new_child.val)
  call void @yc_frame_pop()
  ret void
}

define ptr @std__mem__keep(ptr %ptr) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  %calltmp = call ptr @yc_move_to_root(ptr %ptr.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define ptr @std__mem__keep_string(ptr %ptr) {
entry:
  %ptr1 = alloca ptr, align 8
  store ptr %ptr, ptr %ptr1, align 8
  call void @yc_frame_push()
  %ptr.val = load ptr, ptr %ptr1, align 8
  %calltmp = call ptr @yc_keep_string(ptr %ptr.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std__mem__copy(ptr %dst, ptr %src, i64 %size) {
entry:
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %src2 = alloca ptr, align 8
  store ptr %src, ptr %src2, align 8
  %size3 = alloca i64, align 8
  store i64 %size, ptr %size3, align 4
  call void @yc_frame_push()
  %dst.val = load ptr, ptr %dst1, align 8
  %src.val = load ptr, ptr %src2, align 8
  %size.val = load i64, ptr %size3, align 4
  %calltmp = call ptr @memcpy(ptr %dst.val, ptr %src.val, i64 %size.val)
  call void @yc_frame_pop()
  ret void
}

define void @std__mem__set(ptr %dst, i32 %value, i64 %size) {
entry:
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %value2 = alloca i32, align 4
  store i32 %value, ptr %value2, align 4
  %size3 = alloca i64, align 8
  store i64 %size, ptr %size3, align 4
  call void @yc_frame_push()
  %dst.val = load ptr, ptr %dst1, align 8
  %value.val = load i32, ptr %value2, align 4
  %size.val = load i64, ptr %size3, align 4
  %calltmp = call ptr @memset(ptr %dst.val, i32 %value.val, i64 %size.val)
  call void @yc_frame_pop()
  ret void
}

define i64 @std2__str__len(ptr %s) {
entry:
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %calltmp = call i64 @strlen(ptr %s.val)
  call void @yc_frame_pop()
  ret i64 %calltmp
}

define i32 @std2__str__cmp(ptr %a, ptr %b) {
entry:
  %a1 = alloca ptr, align 8
  store ptr %a, ptr %a1, align 8
  %b2 = alloca ptr, align 8
  store ptr %b, ptr %b2, align 8
  call void @yc_frame_push()
  %a.val = load ptr, ptr %a1, align 8
  %b.val = load ptr, ptr %b2, align 8
  %calltmp = call i32 @strcmp(ptr %a.val, ptr %b.val)
  call void @yc_frame_pop()
  ret i32 %calltmp
}

define ptr @std2__str__copy(ptr %dst, ptr %src) {
entry:
  %dst1 = alloca ptr, align 8
  store ptr %dst, ptr %dst1, align 8
  %src2 = alloca ptr, align 8
  store ptr %src, ptr %src2, align 8
  call void @yc_frame_push()
  %dst.val = load ptr, ptr %dst1, align 8
  %src.val = load ptr, ptr %src2, align 8
  %calltmp = call ptr @strcpy(ptr %dst.val, ptr %src.val)
  %runtime.move = call ptr @yc_move_to_parent(ptr %calltmp)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define i1 @std2__str__eq(ptr %a, ptr %b) {
entry:
  %a1 = alloca ptr, align 8
  store ptr %a, ptr %a1, align 8
  %b2 = alloca ptr, align 8
  store ptr %b, ptr %b2, align 8
  call void @yc_frame_push()
  %a.val = load ptr, ptr %a1, align 8
  %b.val = load ptr, ptr %b2, align 8
  %calltmp = call i32 @strcmp(ptr %a.val, ptr %b.val)
  %cmptmp = icmp eq i32 %calltmp, 0
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define internal %Bytes @std__bytes__invalid() {
entry:
  %Bytes.tmp = alloca %Bytes, align 8
  call void @yc_frame_push()
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  store ptr null, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  store ptr null, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  store i32 0, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  store i32 0, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 false, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct
}

define internal i32 @std__bytes__strlen_local(ptr %s) {
entry:
  %i = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %cmptmp = icmp eq ptr %s.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %s.val2 = load ptr, ptr %s1, align 8
  %i.val = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp3 = icmp ne i32 %string.index.i32, 0
  %1 = zext i1 %cmptmp3 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %i.val4 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val4
}

define internal %Bytes @std__bytes__ensure_cap(%Bytes %b, i32 %needed) {
entry:
  %Bytes.tmp85 = alloca %Bytes, align 8
  %i = alloca i32, align 4
  %data67 = alloca ptr, align 8
  %root62 = alloca ptr, align 8
  %Bytes.tmp48 = alloca %Bytes, align 8
  %root35 = alloca ptr, align 8
  %data31 = alloca ptr, align 8
  %Bytes.tmp = alloca %Bytes, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %next = alloca i32, align 4
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %needed2 = alloca i32, align 4
  store i32 %needed, ptr %needed2, align 4
  call void @yc_frame_push()
  %needed.val = load i32, ptr %needed2, align 4
  %cap.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 3
  %cap.val = load i32, ptr %cap.addr, align 4
  %cmptmp = icmp sle i32 %needed.val, %cap.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %b.val = load %Bytes, ptr %b1, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %b.val

ifcont:                                           ; preds = %entry
  %cap.addr3 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 3
  %cap.val4 = load i32, ptr %cap.addr3, align 4
  store i32 %cap.val4, ptr %next, align 4
  %next.val = load i32, ptr %next, align 4
  %cmptmp5 = icmp slt i32 %next.val, 1
  %1 = zext i1 %cmptmp5 to i32
  %ifcond6 = icmp ne i32 %1, 0
  br i1 %ifcond6, label %then7, label %ifcont8

then7:                                            ; preds = %ifcont
  store i32 1, ptr %next, align 4
  br label %ifcont8

ifcont8:                                          ; preds = %then7, %ifcont
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont8
  %next.val9 = load i32, ptr %next, align 4
  %needed.val10 = load i32, ptr %needed2, align 4
  %cmptmp11 = icmp slt i32 %next.val9, %needed.val10
  %2 = zext i1 %cmptmp11 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %next.val12 = load i32, ptr %next, align 4
  %multmp = mul i32 %next.val12, 2
  store i32 %multmp, ptr %next, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp13 = icmp eq ptr %data.val, null
  %3 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %3, 0
  br i1 %ifcond14, label %then15, label %ifcont22

then15:                                           ; preds = %for.after
  %calltmp = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp, ptr %root, align 8
  %next.val16 = load i32, ptr %next, align 4
  %addtmp = add i32 %next.val16, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp17 = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp17, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val18 = load ptr, ptr %data, align 8
  call void @std__mem__attach_child(ptr %root.val, ptr %data.val18)
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  %root.val19 = load ptr, ptr %root, align 8
  store ptr %root.val19, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  %data.val20 = load ptr, ptr %data, align 8
  store ptr %data.val20, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  store i32 %len.val, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  %next.val21 = load i32, ptr %next, align 4
  store i32 %next.val21, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct

ifcont22:                                         ; preds = %for.after
  %owns.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond23 = icmp ne i1 %owns.val, false
  br i1 %ifcond23, label %then24, label %ifcont60

then24:                                           ; preds = %ifcont22
  %data.addr25 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val26 = load ptr, ptr %data.addr25, align 8
  %next.val27 = load i32, ptr %next, align 4
  %addtmp28 = add i32 %next.val27, 1
  %call.arg.intcast29 = sext i32 %addtmp28 to i64
  %calltmp30 = call ptr @std__mem__realloc(ptr %data.val26, i64 %call.arg.intcast29)
  store ptr %calltmp30, ptr %data31, align 8
  %data.val32 = load ptr, ptr %data31, align 8
  %next.val33 = load i32, ptr %next, align 4
  %string.index.addr.idx.i64 = sext i32 %next.val33 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %data.val32, i64 %string.index.addr.idx.i64
  store i8 0, ptr %string.index.addr, align 1
  %root.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 0
  %root.val34 = load ptr, ptr %root.addr, align 8
  store ptr %root.val34, ptr %root35, align 8
  %root.val36 = load ptr, ptr %root35, align 8
  %cmptmp37 = icmp eq ptr %root.val36, null
  %4 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %4, 0
  br i1 %ifcond38, label %then39, label %else

then39:                                           ; preds = %then24
  %calltmp40 = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp40, ptr %root35, align 8
  %root.val41 = load ptr, ptr %root35, align 8
  %data.val42 = load ptr, ptr %data31, align 8
  call void @std__mem__attach_child(ptr %root.val41, ptr %data.val42)
  br label %ifcont47

else:                                             ; preds = %then24
  %root.val43 = load ptr, ptr %root35, align 8
  %data.addr44 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val45 = load ptr, ptr %data.addr44, align 8
  %data.val46 = load ptr, ptr %data31, align 8
  call void @std__mem__replace_child(ptr %root.val43, ptr %data.val45, ptr %data.val46)
  br label %ifcont47

ifcont47:                                         ; preds = %else, %then39
  %Bytes.field0.addr49 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 0
  %root.val50 = load ptr, ptr %root35, align 8
  store ptr %root.val50, ptr %Bytes.field0.addr49, align 8
  %Bytes.field1.addr51 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 1
  %data.val52 = load ptr, ptr %data31, align 8
  store ptr %data.val52, ptr %Bytes.field1.addr51, align 8
  %Bytes.field2.addr53 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 2
  %len.addr54 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val55 = load i32, ptr %len.addr54, align 4
  store i32 %len.val55, ptr %Bytes.field2.addr53, align 4
  %Bytes.field3.addr56 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 3
  %next.val57 = load i32, ptr %next, align 4
  store i32 %next.val57, ptr %Bytes.field3.addr56, align 4
  %Bytes.field4.addr58 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr58, align 1
  %return.load_struct59 = load %Bytes, ptr %Bytes.tmp48, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct59

ifcont60:                                         ; preds = %ifcont22
  %calltmp61 = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp61, ptr %root62, align 8
  %next.val63 = load i32, ptr %next, align 4
  %addtmp64 = add i32 %next.val63, 1
  %call.arg.intcast65 = sext i32 %addtmp64 to i64
  %calltmp66 = call ptr @std__mem__calloc(i64 %call.arg.intcast65, i64 1)
  store ptr %calltmp66, ptr %data67, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond68

for.cond68:                                       ; preds = %for.inc70, %ifcont60
  %i.val = load i32, ptr %i, align 4
  %len.addr72 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val73 = load i32, ptr %len.addr72, align 4
  %cmptmp74 = icmp slt i32 %i.val, %len.val73
  %5 = zext i1 %cmptmp74 to i32
  %forcond75 = icmp ne i32 %5, 0
  br i1 %forcond75, label %for.body69, label %for.after71

for.body69:                                       ; preds = %for.cond68
  %data.val76 = load ptr, ptr %data67, align 8
  %i.val77 = load i32, ptr %i, align 4
  %string.index.addr.idx.i6478 = sext i32 %i.val77 to i64
  %string.index.addr79 = getelementptr inbounds i8, ptr %data.val76, i64 %string.index.addr.idx.i6478
  %data.addr80 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val81 = load ptr, ptr %data.addr80, align 8
  %i.val82 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val82 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val81, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr79, align 1
  br label %for.inc70

for.inc70:                                        ; preds = %for.body69
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond68

for.after71:                                      ; preds = %for.cond68
  %root.val83 = load ptr, ptr %root62, align 8
  %data.val84 = load ptr, ptr %data67, align 8
  call void @std__mem__attach_child(ptr %root.val83, ptr %data.val84)
  %Bytes.field0.addr86 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 0
  %root.val87 = load ptr, ptr %root62, align 8
  store ptr %root.val87, ptr %Bytes.field0.addr86, align 8
  %Bytes.field1.addr88 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 1
  %data.val89 = load ptr, ptr %data67, align 8
  store ptr %data.val89, ptr %Bytes.field1.addr88, align 8
  %Bytes.field2.addr90 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 2
  %len.addr91 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val92 = load i32, ptr %len.addr91, align 4
  store i32 %len.val92, ptr %Bytes.field2.addr90, align 4
  %Bytes.field3.addr93 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 3
  %next.val94 = load i32, ptr %next, align 4
  store i32 %next.val94, ptr %Bytes.field3.addr93, align 4
  %Bytes.field4.addr95 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr95, align 1
  %return.load_struct96 = load %Bytes, ptr %Bytes.tmp85, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct96
}

define %Bytes @std__bytes__new(i32 %cap) {
entry:
  %Bytes.tmp = alloca %Bytes, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %cap1 = alloca i32, align 4
  store i32 %cap, ptr %cap1, align 4
  call void @yc_frame_push()
  %cap.val = load i32, ptr %cap1, align 4
  %cmptmp = icmp slt i32 %cap.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp = call %Bytes @std__bytes__invalid()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp

ifcont:                                           ; preds = %entry
  %calltmp2 = call ptr @std__mem__alloc(i64 1)
  store ptr %calltmp2, ptr %root, align 8
  %cap.val3 = load i32, ptr %cap1, align 4
  %addtmp = add i32 %cap.val3, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp4 = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp4, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val = load ptr, ptr %data, align 8
  call void @std__mem__attach_child(ptr %root.val, ptr %data.val)
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  %root.val5 = load ptr, ptr %root, align 8
  store ptr %root.val5, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  %data.val6 = load ptr, ptr %data, align 8
  store ptr %data.val6, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  store i32 0, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  %cap.val7 = load i32, ptr %cap1, align 4
  store i32 %cap.val7, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct
}

define %Bytes @std__bytes__wrap(ptr %data, i32 %len) {
entry:
  %Bytes.tmp = alloca %Bytes, align 8
  %data1 = alloca ptr, align 8
  store ptr %data, ptr %data1, align 8
  %len2 = alloca i32, align 4
  store i32 %len, ptr %len2, align 4
  call void @yc_frame_push()
  %data.val = load ptr, ptr %data1, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %len.val = load i32, ptr %len2, align 4
  %cmptmp3 = icmp slt i32 %len.val, 0
  %1 = zext i1 %cmptmp3 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %calltmp = call %Bytes @std__bytes__invalid()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp

ifcont:                                           ; preds = %lor.end
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  store ptr null, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  %data.val4 = load ptr, ptr %data1, align 8
  store ptr %data.val4, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  %len.val5 = load i32, ptr %len2, align 4
  store i32 %len.val5, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  %len.val6 = load i32, ptr %len2, align 4
  store i32 %len.val6, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 false, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct
}

define %Bytes @std__bytes__from_string(ptr %text) {
entry:
  %i = alloca i32, align 4
  %out = alloca %Bytes, align 8
  %n = alloca i32, align 4
  %text1 = alloca ptr, align 8
  store ptr %text, ptr %text1, align 8
  call void @yc_frame_push()
  %text.val = load ptr, ptr %text1, align 8
  %calltmp = call i32 @std__bytes__strlen_local(ptr %text.val)
  store i32 %calltmp, ptr %n, align 4
  %n.val = load i32, ptr %n, align 4
  %calltmp2 = call %Bytes @std__bytes__new(i32 %n.val)
  store %Bytes %calltmp2, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val3 = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val3
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %i.val4 = load i32, ptr %i, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %i.val4 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val, i64 %string.expr.index.addr.idx.i64
  %text.val5 = load ptr, ptr %text1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %text1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %assign_trunc = trunc i32 %string.index.i32 to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %len.addr = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %n.val7 = load i32, ptr %n, align 4
  store i32 %n.val7, ptr %len.addr, align 4
  %out.val = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val
}

define ptr @std__bytes__to_string(%Bytes %b) {
entry:
  %i = alloca i32, align 4
  %out = alloca ptr, align 8
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %addtmp = add i32 %len.val, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp = call ptr @std__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %len.addr2 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val3 = load i32, ptr %len.addr2, align 4
  %cmptmp4 = icmp slt i32 %i.val, %len.val3
  %1 = zext i1 %cmptmp4 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %out.val = load ptr, ptr %out, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.index.addr.idx.i64 = sext i32 %i.val5 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 %string.index.addr.idx.i64
  %data.addr6 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %i.val8 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val8 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val7, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %out.val9 = load ptr, ptr %out, align 8
  %runtime.move10 = call ptr @yc_move_to_parent(ptr %out.val9)
  call void @yc_frame_pop()
  ret ptr %runtime.move10
}

define ptr @std__bytes__byte_to_string(i32 %value) {
entry:
  %out = alloca ptr, align 8
  %value1 = alloca i32, align 4
  store i32 %value, ptr %value1, align 4
  call void @yc_frame_push()
  %calltmp = call ptr @std__mem__calloc(i64 2, i64 1)
  store ptr %calltmp, ptr %out, align 8
  %out.val = load ptr, ptr %out, align 8
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 0
  %value.val = load i32, ptr %value1, align 4
  %andtmp = and i32 %value.val, 255
  %assign_trunc = trunc i32 %andtmp to i8
  store i8 %assign_trunc, ptr %string.index.addr, align 1
  %out.val2 = load ptr, ptr %out, align 8
  %runtime.move = call ptr @yc_move_to_parent(ptr %out.val2)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std__bytes__free(%Bytes %b) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %owns.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond = icmp ne i1 %owns.val, false
  br i1 %ifcond, label %then, label %ifcont12

then:                                             ; preds = %entry
  %root.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 0
  %root.val = load ptr, ptr %root.addr, align 8
  %cmptmp = icmp ne ptr %root.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond2 = icmp ne i32 %0, 0
  br i1 %ifcond2, label %then3, label %else

then3:                                            ; preds = %then
  %root.addr4 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 0
  %root.val5 = load ptr, ptr %root.addr4, align 8
  call void @std__mem__free(ptr %root.val5)
  br label %ifcont11

else:                                             ; preds = %then
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp6 = icmp ne ptr %data.val, null
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont

then8:                                            ; preds = %else
  %data.addr9 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val10 = load ptr, ptr %data.addr9, align 8
  call void @std__mem__free(ptr %data.val10)
  br label %ifcont

ifcont:                                           ; preds = %then8, %else
  br label %ifcont11

ifcont11:                                         ; preds = %ifcont, %then3
  br label %ifcont12

ifcont12:                                         ; preds = %ifcont11, %entry
  call void @yc_frame_pop()
  ret void
}

define i32 @std__bytes__get(%Bytes %b, i32 %index) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %index2 = alloca i32, align 4
  store i32 %index, ptr %index2, align 4
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end4, label %lor.rhs3

lor.rhs:                                          ; preds = %lor.end4
  %index.val7 = load i32, ptr %index2, align 4
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp8 = icmp sge i32 %index.val7, %len.val
  %1 = zext i1 %cmptmp8 to i32
  %rhsbool9 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end4
  %lortmp10 = phi i1 [ true, %lor.end4 ], [ %rhsbool9, %lor.rhs ]
  %2 = zext i1 %lortmp10 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs3:                                         ; preds = %entry
  %index.val = load i32, ptr %index2, align 4
  %cmptmp5 = icmp slt i32 %index.val, 0
  %3 = zext i1 %cmptmp5 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end4

lor.end4:                                         ; preds = %lor.rhs3, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs3 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool6 = icmp ne i32 %4, 0
  br i1 %lhsbool6, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %lor.end
  %data.addr11 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val12 = load ptr, ptr %data.addr11, align 8
  %index.val13 = load i32, ptr %index2, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %index.val13 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val12, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %andtmp = and i32 %string.expr.index.i32, 255
  call void @yc_frame_pop()
  ret i32 %andtmp
}

define void @std__bytes__set(%Bytes %b, i32 %index, i32 %value) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %index2 = alloca i32, align 4
  store i32 %index, ptr %index2, align 4
  %value3 = alloca i32, align 4
  store i32 %value, ptr %value3, align 4
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end5, label %lor.rhs4

lor.rhs:                                          ; preds = %lor.end5
  %index.val8 = load i32, ptr %index2, align 4
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp9 = icmp sge i32 %index.val8, %len.val
  %1 = zext i1 %cmptmp9 to i32
  %rhsbool10 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp11 = phi i1 [ true, %lor.end5 ], [ %rhsbool10, %lor.rhs ]
  %2 = zext i1 %lortmp11 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %entry
  %index.val = load i32, ptr %index2, align 4
  %cmptmp6 = icmp slt i32 %index.val, 0
  %3 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs4 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool7 = icmp ne i32 %4, 0
  br i1 %lhsbool7, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  call void @yc_frame_pop()
  ret void

ifcont:                                           ; preds = %lor.end
  %data.addr12 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val13 = load ptr, ptr %data.addr12, align 8
  %index.val14 = load i32, ptr %index2, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %index.val14 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val13, i64 %string.expr.index.addr.idx.i64
  %value.val = load i32, ptr %value3, align 4
  %andtmp = and i32 %value.val, 255
  %assign_trunc = trunc i32 %andtmp to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  call void @yc_frame_pop()
  ret void
}

define %Bytes @std__bytes__append(%Bytes %b, i32 %value) {
entry:
  %out = alloca %Bytes, align 8
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %value2 = alloca i32, align 4
  store i32 %value, ptr %value2, align 4
  call void @yc_frame_push()
  %b.val = load %Bytes, ptr %b1, align 8
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %addtmp = add i32 %len.val, 1
  %calltmp = call %Bytes @std__bytes__ensure_cap(%Bytes %b.val, i32 %addtmp)
  store %Bytes %calltmp, ptr %out, align 8
  %data.addr = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %len.addr3 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %len.val4 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val, i64 %string.expr.index.addr.idx.i64
  %value.val = load i32, ptr %value2, align 4
  %andtmp = and i32 %value.val, 255
  %assign_trunc = trunc i32 %andtmp to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  %len.addr5 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %compound.member.current = load i32, ptr %len.addr5, align 4
  %compound.add = add i32 %compound.member.current, 1
  store i32 %compound.add, ptr %len.addr5, align 4
  %data.addr6 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %len.addr8 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %len.val9 = load i32, ptr %len.addr8, align 4
  %string.expr.index.addr.idx.i6410 = sext i32 %len.val9 to i64
  %string.expr.index.addr11 = getelementptr inbounds i8, ptr %data.val7, i64 %string.expr.index.addr.idx.i6410
  store i8 0, ptr %string.expr.index.addr11, align 1
  %out.val = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val
}

define %Bytes @std__bytes__slice(%Bytes %b, i32 %start, i32 %count) {
entry:
  %i = alloca i32, align 4
  %out = alloca %Bytes, align 8
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %count3 = alloca i32, align 4
  store i32 %count, ptr %count3, align 4
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end7, label %lor.rhs6

lor.rhs:                                          ; preds = %lor.end5
  %start.val14 = load i32, ptr %start2, align 4
  %count.val15 = load i32, ptr %count3, align 4
  %addtmp = add i32 %start.val14, %count.val15
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp16 = icmp sgt i32 %addtmp, %len.val
  %1 = zext i1 %cmptmp16 to i32
  %rhsbool17 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp18 = phi i1 [ true, %lor.end5 ], [ %rhsbool17, %lor.rhs ]
  %2 = zext i1 %lortmp18 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %lor.end7
  %count.val = load i32, ptr %count3, align 4
  %cmptmp10 = icmp slt i32 %count.val, 0
  %3 = zext i1 %cmptmp10 to i32
  %rhsbool11 = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %lor.end7
  %lortmp12 = phi i1 [ true, %lor.end7 ], [ %rhsbool11, %lor.rhs4 ]
  %4 = zext i1 %lortmp12 to i32
  %lhsbool13 = icmp ne i32 %4, 0
  br i1 %lhsbool13, label %lor.end, label %lor.rhs

lor.rhs6:                                         ; preds = %entry
  %start.val = load i32, ptr %start2, align 4
  %cmptmp8 = icmp slt i32 %start.val, 0
  %5 = zext i1 %cmptmp8 to i32
  %rhsbool = icmp ne i32 %5, 0
  br label %lor.end7

lor.end7:                                         ; preds = %lor.rhs6, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs6 ]
  %6 = zext i1 %lortmp to i32
  %lhsbool9 = icmp ne i32 %6, 0
  br i1 %lhsbool9, label %lor.end5, label %lor.rhs4

then:                                             ; preds = %lor.end
  %calltmp = call %Bytes @std__bytes__invalid()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp

ifcont:                                           ; preds = %lor.end
  %count.val19 = load i32, ptr %count3, align 4
  %calltmp20 = call %Bytes @std__bytes__new(i32 %count.val19)
  store %Bytes %calltmp20, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %count.val21 = load i32, ptr %count3, align 4
  %cmptmp22 = icmp slt i32 %i.val, %count.val21
  %7 = zext i1 %cmptmp22 to i32
  %forcond = icmp ne i32 %7, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr23 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val24 = load ptr, ptr %data.addr23, align 8
  %i.val25 = load i32, ptr %i, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %i.val25 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val24, i64 %string.expr.index.addr.idx.i64
  %data.addr26 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val27 = load ptr, ptr %data.addr26, align 8
  %start.val28 = load i32, ptr %start2, align 4
  %i.val29 = load i32, ptr %i, align 4
  %addtmp30 = add i32 %start.val28, %i.val29
  %string.expr.index.ptr.idx.i64 = sext i32 %addtmp30 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val27, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %len.addr31 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %count.val32 = load i32, ptr %count3, align 4
  store i32 %count.val32, ptr %len.addr31, align 4
  %out.val = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val
}

define %Bytes @std__bytes__clone(%Bytes %b) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %b.val = load %Bytes, ptr %b1, align 8
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %calltmp = call %Bytes @std__bytes__slice(%Bytes %b.val, i32 0, i32 %len.val)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp
}

define i1 @std__bytes__eq(%Bytes %a, %Bytes %b) {
entry:
  %i = alloca i32, align 4
  %a1 = alloca %Bytes, align 8
  store %Bytes %a, ptr %a1, align 8
  %b2 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b2, align 8
  call void @yc_frame_push()
  %len.addr = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %len.addr3 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %cmptmp = icmp ne i32 %len.val, %len.val4
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  %data.addr = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp5 = icmp eq ptr %data.val, null
  %1 = zext i1 %cmptmp5 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont
  %data.addr6 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %cmptmp8 = icmp eq ptr %data.val7, null
  %2 = zext i1 %cmptmp8 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont
  %lortmp = phi i1 [ true, %ifcont ], [ %rhsbool, %lor.rhs ]
  %3 = zext i1 %lortmp to i32
  %ifcond9 = icmp ne i32 %3, 0
  br i1 %ifcond9, label %then10, label %ifcont16

then10:                                           ; preds = %lor.end
  %data.addr11 = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 1
  %data.val12 = load ptr, ptr %data.addr11, align 8
  %data.addr13 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 1
  %data.val14 = load ptr, ptr %data.addr13, align 8
  %cmptmp15 = icmp eq ptr %data.val12, %data.val14
  %4 = zext i1 %cmptmp15 to i32
  %return.intcast = trunc i32 %4 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast

ifcont16:                                         ; preds = %lor.end
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont16
  %i.val = load i32, ptr %i, align 4
  %len.addr17 = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 2
  %len.val18 = load i32, ptr %len.addr17, align 4
  %cmptmp19 = icmp slt i32 %i.val, %len.val18
  %5 = zext i1 %cmptmp19 to i32
  %forcond = icmp ne i32 %5, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr20 = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 1
  %data.val21 = load ptr, ptr %data.addr20, align 8
  %i.val22 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val22 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val21, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %andtmp = and i32 %string.expr.index.i32, 255
  %data.addr23 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 1
  %data.val24 = load ptr, ptr %data.addr23, align 8
  %i.val25 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6426 = sext i32 %i.val25 to i64
  %string.expr.index.ptr27 = getelementptr inbounds i8, ptr %data.val24, i64 %string.expr.index.ptr.idx.i6426
  %string.expr.index.load28 = load i8, ptr %string.expr.index.ptr27, align 1
  %string.expr.index.i3229 = zext i8 %string.expr.index.load28 to i32
  %andtmp30 = and i32 %string.expr.index.i3229, 255
  %cmptmp31 = icmp ne i32 %andtmp, %andtmp30
  %6 = zext i1 %cmptmp31 to i32
  %ifcond32 = icmp ne i32 %6, 0
  br i1 %ifcond32, label %then33, label %ifcont34

for.inc:                                          ; preds = %ifcont34
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then33:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont34:                                         ; preds = %for.body
  br label %for.inc
}

define internal %Bytes @std2__bytes__invalid() {
entry:
  %Bytes.tmp = alloca %Bytes, align 8
  call void @yc_frame_push()
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  store ptr null, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  store ptr null, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  store i32 0, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  store i32 0, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 false, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct
}

define internal i32 @std2__bytes__strlen_local(ptr %s) {
entry:
  %i = alloca i32, align 4
  %s1 = alloca ptr, align 8
  store ptr %s, ptr %s1, align 8
  call void @yc_frame_push()
  %s.val = load ptr, ptr %s1, align 8
  %cmptmp = icmp eq ptr %s.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %s.val2 = load ptr, ptr %s1, align 8
  %i.val = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %s1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %cmptmp3 = icmp ne i32 %string.index.i32, 0
  %1 = zext i1 %cmptmp3 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %i.val4 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val4
}

define internal %Bytes @std2__bytes__ensure_cap(%Bytes %b, i32 %needed) {
entry:
  %Bytes.tmp85 = alloca %Bytes, align 8
  %i = alloca i32, align 4
  %data67 = alloca ptr, align 8
  %root62 = alloca ptr, align 8
  %Bytes.tmp48 = alloca %Bytes, align 8
  %root35 = alloca ptr, align 8
  %data31 = alloca ptr, align 8
  %Bytes.tmp = alloca %Bytes, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %next = alloca i32, align 4
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %needed2 = alloca i32, align 4
  store i32 %needed, ptr %needed2, align 4
  call void @yc_frame_push()
  %needed.val = load i32, ptr %needed2, align 4
  %cap.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 3
  %cap.val = load i32, ptr %cap.addr, align 4
  %cmptmp = icmp sle i32 %needed.val, %cap.val
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %b.val = load %Bytes, ptr %b1, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %b.val

ifcont:                                           ; preds = %entry
  %cap.addr3 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 3
  %cap.val4 = load i32, ptr %cap.addr3, align 4
  store i32 %cap.val4, ptr %next, align 4
  %next.val = load i32, ptr %next, align 4
  %cmptmp5 = icmp slt i32 %next.val, 1
  %1 = zext i1 %cmptmp5 to i32
  %ifcond6 = icmp ne i32 %1, 0
  br i1 %ifcond6, label %then7, label %ifcont8

then7:                                            ; preds = %ifcont
  store i32 1, ptr %next, align 4
  br label %ifcont8

ifcont8:                                          ; preds = %then7, %ifcont
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont8
  %next.val9 = load i32, ptr %next, align 4
  %needed.val10 = load i32, ptr %needed2, align 4
  %cmptmp11 = icmp slt i32 %next.val9, %needed.val10
  %2 = zext i1 %cmptmp11 to i32
  %forcond = icmp ne i32 %2, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %next.val12 = load i32, ptr %next, align 4
  %multmp = mul i32 %next.val12, 2
  store i32 %multmp, ptr %next, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp13 = icmp eq ptr %data.val, null
  %3 = zext i1 %cmptmp13 to i32
  %ifcond14 = icmp ne i32 %3, 0
  br i1 %ifcond14, label %then15, label %ifcont22

then15:                                           ; preds = %for.after
  %calltmp = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp, ptr %root, align 8
  %next.val16 = load i32, ptr %next, align 4
  %addtmp = add i32 %next.val16, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp17 = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp17, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val18 = load ptr, ptr %data, align 8
  call void @std2__mem__attach_child(ptr %root.val, ptr %data.val18)
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  %root.val19 = load ptr, ptr %root, align 8
  store ptr %root.val19, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  %data.val20 = load ptr, ptr %data, align 8
  store ptr %data.val20, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  store i32 %len.val, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  %next.val21 = load i32, ptr %next, align 4
  store i32 %next.val21, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct

ifcont22:                                         ; preds = %for.after
  %owns.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond23 = icmp ne i1 %owns.val, false
  br i1 %ifcond23, label %then24, label %ifcont60

then24:                                           ; preds = %ifcont22
  %data.addr25 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val26 = load ptr, ptr %data.addr25, align 8
  %next.val27 = load i32, ptr %next, align 4
  %addtmp28 = add i32 %next.val27, 1
  %call.arg.intcast29 = sext i32 %addtmp28 to i64
  %calltmp30 = call ptr @std2__mem__realloc(ptr %data.val26, i64 %call.arg.intcast29)
  store ptr %calltmp30, ptr %data31, align 8
  %data.val32 = load ptr, ptr %data31, align 8
  %next.val33 = load i32, ptr %next, align 4
  %string.index.addr.idx.i64 = sext i32 %next.val33 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %data.val32, i64 %string.index.addr.idx.i64
  store i8 0, ptr %string.index.addr, align 1
  %root.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 0
  %root.val34 = load ptr, ptr %root.addr, align 8
  store ptr %root.val34, ptr %root35, align 8
  %root.val36 = load ptr, ptr %root35, align 8
  %cmptmp37 = icmp eq ptr %root.val36, null
  %4 = zext i1 %cmptmp37 to i32
  %ifcond38 = icmp ne i32 %4, 0
  br i1 %ifcond38, label %then39, label %else

then39:                                           ; preds = %then24
  %calltmp40 = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp40, ptr %root35, align 8
  %root.val41 = load ptr, ptr %root35, align 8
  %data.val42 = load ptr, ptr %data31, align 8
  call void @std2__mem__attach_child(ptr %root.val41, ptr %data.val42)
  br label %ifcont47

else:                                             ; preds = %then24
  %root.val43 = load ptr, ptr %root35, align 8
  %data.addr44 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val45 = load ptr, ptr %data.addr44, align 8
  %data.val46 = load ptr, ptr %data31, align 8
  call void @std2__mem__replace_child(ptr %root.val43, ptr %data.val45, ptr %data.val46)
  br label %ifcont47

ifcont47:                                         ; preds = %else, %then39
  %Bytes.field0.addr49 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 0
  %root.val50 = load ptr, ptr %root35, align 8
  store ptr %root.val50, ptr %Bytes.field0.addr49, align 8
  %Bytes.field1.addr51 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 1
  %data.val52 = load ptr, ptr %data31, align 8
  store ptr %data.val52, ptr %Bytes.field1.addr51, align 8
  %Bytes.field2.addr53 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 2
  %len.addr54 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val55 = load i32, ptr %len.addr54, align 4
  store i32 %len.val55, ptr %Bytes.field2.addr53, align 4
  %Bytes.field3.addr56 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 3
  %next.val57 = load i32, ptr %next, align 4
  store i32 %next.val57, ptr %Bytes.field3.addr56, align 4
  %Bytes.field4.addr58 = getelementptr inbounds %Bytes, ptr %Bytes.tmp48, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr58, align 1
  %return.load_struct59 = load %Bytes, ptr %Bytes.tmp48, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct59

ifcont60:                                         ; preds = %ifcont22
  %calltmp61 = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp61, ptr %root62, align 8
  %next.val63 = load i32, ptr %next, align 4
  %addtmp64 = add i32 %next.val63, 1
  %call.arg.intcast65 = sext i32 %addtmp64 to i64
  %calltmp66 = call ptr @std2__mem__calloc(i64 %call.arg.intcast65, i64 1)
  store ptr %calltmp66, ptr %data67, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond68

for.cond68:                                       ; preds = %for.inc70, %ifcont60
  %i.val = load i32, ptr %i, align 4
  %len.addr72 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val73 = load i32, ptr %len.addr72, align 4
  %cmptmp74 = icmp slt i32 %i.val, %len.val73
  %5 = zext i1 %cmptmp74 to i32
  %forcond75 = icmp ne i32 %5, 0
  br i1 %forcond75, label %for.body69, label %for.after71

for.body69:                                       ; preds = %for.cond68
  %data.val76 = load ptr, ptr %data67, align 8
  %i.val77 = load i32, ptr %i, align 4
  %string.index.addr.idx.i6478 = sext i32 %i.val77 to i64
  %string.index.addr79 = getelementptr inbounds i8, ptr %data.val76, i64 %string.index.addr.idx.i6478
  %data.addr80 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val81 = load ptr, ptr %data.addr80, align 8
  %i.val82 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val82 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val81, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr79, align 1
  br label %for.inc70

for.inc70:                                        ; preds = %for.body69
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond68

for.after71:                                      ; preds = %for.cond68
  %root.val83 = load ptr, ptr %root62, align 8
  %data.val84 = load ptr, ptr %data67, align 8
  call void @std2__mem__attach_child(ptr %root.val83, ptr %data.val84)
  %Bytes.field0.addr86 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 0
  %root.val87 = load ptr, ptr %root62, align 8
  store ptr %root.val87, ptr %Bytes.field0.addr86, align 8
  %Bytes.field1.addr88 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 1
  %data.val89 = load ptr, ptr %data67, align 8
  store ptr %data.val89, ptr %Bytes.field1.addr88, align 8
  %Bytes.field2.addr90 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 2
  %len.addr91 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val92 = load i32, ptr %len.addr91, align 4
  store i32 %len.val92, ptr %Bytes.field2.addr90, align 4
  %Bytes.field3.addr93 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 3
  %next.val94 = load i32, ptr %next, align 4
  store i32 %next.val94, ptr %Bytes.field3.addr93, align 4
  %Bytes.field4.addr95 = getelementptr inbounds %Bytes, ptr %Bytes.tmp85, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr95, align 1
  %return.load_struct96 = load %Bytes, ptr %Bytes.tmp85, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct96
}

define %Bytes @std2__bytes__new(i32 %cap) {
entry:
  %Bytes.tmp = alloca %Bytes, align 8
  %data = alloca ptr, align 8
  %root = alloca ptr, align 8
  %cap1 = alloca i32, align 4
  store i32 %cap, ptr %cap1, align 4
  call void @yc_frame_push()
  %cap.val = load i32, ptr %cap1, align 4
  %cmptmp = icmp slt i32 %cap.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp = call %Bytes @std2__bytes__invalid()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp

ifcont:                                           ; preds = %entry
  %calltmp2 = call ptr @std2__mem__alloc(i64 1)
  store ptr %calltmp2, ptr %root, align 8
  %cap.val3 = load i32, ptr %cap1, align 4
  %addtmp = add i32 %cap.val3, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp4 = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp4, ptr %data, align 8
  %root.val = load ptr, ptr %root, align 8
  %data.val = load ptr, ptr %data, align 8
  call void @std2__mem__attach_child(ptr %root.val, ptr %data.val)
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  %root.val5 = load ptr, ptr %root, align 8
  store ptr %root.val5, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  %data.val6 = load ptr, ptr %data, align 8
  store ptr %data.val6, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  store i32 0, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  %cap.val7 = load i32, ptr %cap1, align 4
  store i32 %cap.val7, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 true, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct
}

define %Bytes @std2__bytes__empty() {
entry:
  call void @yc_frame_push()
  %calltmp = call %Bytes @std2__bytes__new(i32 0)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp
}

define i1 @std2__bytes__is_valid(%Bytes %b) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp ne ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define i1 @std2__bytes__is_empty(%Bytes %b) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp = icmp eq i32 %len.val, 0
  %0 = zext i1 %cmptmp to i32
  %return.intcast = trunc i32 %0 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast
}

define %Bytes @std2__bytes__wrap(ptr %data, i32 %len) {
entry:
  %Bytes.tmp = alloca %Bytes, align 8
  %data1 = alloca ptr, align 8
  store ptr %data, ptr %data1, align 8
  %len2 = alloca i32, align 4
  store i32 %len, ptr %len2, align 4
  call void @yc_frame_push()
  %data.val = load ptr, ptr %data1, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %entry
  %len.val = load i32, ptr %len2, align 4
  %cmptmp3 = icmp slt i32 %len.val, 0
  %1 = zext i1 %cmptmp3 to i32
  %rhsbool = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs ]
  %2 = zext i1 %lortmp to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %lor.end
  %calltmp = call %Bytes @std2__bytes__invalid()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp

ifcont:                                           ; preds = %lor.end
  %Bytes.field0.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 0
  store ptr null, ptr %Bytes.field0.addr, align 8
  %Bytes.field1.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 1
  %data.val4 = load ptr, ptr %data1, align 8
  store ptr %data.val4, ptr %Bytes.field1.addr, align 8
  %Bytes.field2.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 2
  %len.val5 = load i32, ptr %len2, align 4
  store i32 %len.val5, ptr %Bytes.field2.addr, align 4
  %Bytes.field3.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 3
  %len.val6 = load i32, ptr %len2, align 4
  store i32 %len.val6, ptr %Bytes.field3.addr, align 4
  %Bytes.field4.addr = getelementptr inbounds %Bytes, ptr %Bytes.tmp, i32 0, i32 4
  store i1 false, ptr %Bytes.field4.addr, align 1
  %return.load_struct = load %Bytes, ptr %Bytes.tmp, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %return.load_struct
}

define %Bytes @std2__bytes__from_string(ptr %text) {
entry:
  %i = alloca i32, align 4
  %out = alloca %Bytes, align 8
  %n = alloca i32, align 4
  %text1 = alloca ptr, align 8
  store ptr %text, ptr %text1, align 8
  call void @yc_frame_push()
  %text.val = load ptr, ptr %text1, align 8
  %calltmp = call i32 @std2__bytes__strlen_local(ptr %text.val)
  store i32 %calltmp, ptr %n, align 4
  %n.val = load i32, ptr %n, align 4
  %calltmp2 = call %Bytes @std2__bytes__new(i32 %n.val)
  store %Bytes %calltmp2, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val3 = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val3
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %i.val4 = load i32, ptr %i, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %i.val4 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val, i64 %string.expr.index.addr.idx.i64
  %text.val5 = load ptr, ptr %text1, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %text1, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val6 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %assign_trunc = trunc i32 %string.index.i32 to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %len.addr = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %n.val7 = load i32, ptr %n, align 4
  store i32 %n.val7, ptr %len.addr, align 4
  %out.val = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val
}

define ptr @std2__bytes__to_string(%Bytes %b) {
entry:
  %i = alloca i32, align 4
  %out = alloca ptr, align 8
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %runtime.move = call ptr @yc_move_to_parent(ptr null)
  call void @yc_frame_pop()
  ret ptr %runtime.move

ifcont:                                           ; preds = %entry
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %addtmp = add i32 %len.val, 1
  %call.arg.intcast = sext i32 %addtmp to i64
  %calltmp = call ptr @std2__mem__calloc(i64 %call.arg.intcast, i64 1)
  store ptr %calltmp, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %len.addr2 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val3 = load i32, ptr %len.addr2, align 4
  %cmptmp4 = icmp slt i32 %i.val, %len.val3
  %1 = zext i1 %cmptmp4 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %out.val = load ptr, ptr %out, align 8
  %i.val5 = load i32, ptr %i, align 4
  %string.index.addr.idx.i64 = sext i32 %i.val5 to i64
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 %string.index.addr.idx.i64
  %data.addr6 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %i.val8 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val8 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val7, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %out.val9 = load ptr, ptr %out, align 8
  %runtime.move10 = call ptr @yc_move_to_parent(ptr %out.val9)
  call void @yc_frame_pop()
  ret ptr %runtime.move10
}

define ptr @std2__bytes__byte_to_string(i32 %value) {
entry:
  %out = alloca ptr, align 8
  %value1 = alloca i32, align 4
  store i32 %value, ptr %value1, align 4
  call void @yc_frame_push()
  %calltmp = call ptr @std2__mem__calloc(i64 2, i64 1)
  store ptr %calltmp, ptr %out, align 8
  %out.val = load ptr, ptr %out, align 8
  %string.index.addr = getelementptr inbounds i8, ptr %out.val, i64 0
  %value.val = load i32, ptr %value1, align 4
  %andtmp = and i32 %value.val, 255
  %assign_trunc = trunc i32 %andtmp to i8
  store i8 %assign_trunc, ptr %string.index.addr, align 1
  %out.val2 = load ptr, ptr %out, align 8
  %runtime.move = call ptr @yc_move_to_parent(ptr %out.val2)
  call void @yc_frame_pop()
  ret ptr %runtime.move
}

define void @std2__bytes__free(%Bytes %b) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %owns.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 4
  %owns.val = load i1, ptr %owns.addr, align 1
  %ifcond = icmp ne i1 %owns.val, false
  br i1 %ifcond, label %then, label %ifcont12

then:                                             ; preds = %entry
  %root.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 0
  %root.val = load ptr, ptr %root.addr, align 8
  %cmptmp = icmp ne ptr %root.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond2 = icmp ne i32 %0, 0
  br i1 %ifcond2, label %then3, label %else

then3:                                            ; preds = %then
  %root.addr4 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 0
  %root.val5 = load ptr, ptr %root.addr4, align 8
  call void @std2__mem__free(ptr %root.val5)
  br label %ifcont11

else:                                             ; preds = %then
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp6 = icmp ne ptr %data.val, null
  %1 = zext i1 %cmptmp6 to i32
  %ifcond7 = icmp ne i32 %1, 0
  br i1 %ifcond7, label %then8, label %ifcont

then8:                                            ; preds = %else
  %data.addr9 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val10 = load ptr, ptr %data.addr9, align 8
  call void @std2__mem__free(ptr %data.val10)
  br label %ifcont

ifcont:                                           ; preds = %then8, %else
  br label %ifcont11

ifcont11:                                         ; preds = %ifcont, %then3
  br label %ifcont12

ifcont12:                                         ; preds = %ifcont11, %entry
  call void @yc_frame_pop()
  ret void
}

define i32 @std2__bytes__get(%Bytes %b, i32 %index) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %index2 = alloca i32, align 4
  store i32 %index, ptr %index2, align 4
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end4, label %lor.rhs3

lor.rhs:                                          ; preds = %lor.end4
  %index.val7 = load i32, ptr %index2, align 4
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp8 = icmp sge i32 %index.val7, %len.val
  %1 = zext i1 %cmptmp8 to i32
  %rhsbool9 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end4
  %lortmp10 = phi i1 [ true, %lor.end4 ], [ %rhsbool9, %lor.rhs ]
  %2 = zext i1 %lortmp10 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs3:                                         ; preds = %entry
  %index.val = load i32, ptr %index2, align 4
  %cmptmp5 = icmp slt i32 %index.val, 0
  %3 = zext i1 %cmptmp5 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end4

lor.end4:                                         ; preds = %lor.rhs3, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs3 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool6 = icmp ne i32 %4, 0
  br i1 %lhsbool6, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  call void @yc_frame_pop()
  ret i32 0

ifcont:                                           ; preds = %lor.end
  %data.addr11 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val12 = load ptr, ptr %data.addr11, align 8
  %index.val13 = load i32, ptr %index2, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %index.val13 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val12, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %andtmp = and i32 %string.expr.index.i32, 255
  call void @yc_frame_pop()
  ret i32 %andtmp
}

define void @std2__bytes__set(%Bytes %b, i32 %index, i32 %value) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %index2 = alloca i32, align 4
  store i32 %index, ptr %index2, align 4
  %value3 = alloca i32, align 4
  store i32 %value, ptr %value3, align 4
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end5, label %lor.rhs4

lor.rhs:                                          ; preds = %lor.end5
  %index.val8 = load i32, ptr %index2, align 4
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp9 = icmp sge i32 %index.val8, %len.val
  %1 = zext i1 %cmptmp9 to i32
  %rhsbool10 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp11 = phi i1 [ true, %lor.end5 ], [ %rhsbool10, %lor.rhs ]
  %2 = zext i1 %lortmp11 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %entry
  %index.val = load i32, ptr %index2, align 4
  %cmptmp6 = icmp slt i32 %index.val, 0
  %3 = zext i1 %cmptmp6 to i32
  %rhsbool = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs4 ]
  %4 = zext i1 %lortmp to i32
  %lhsbool7 = icmp ne i32 %4, 0
  br i1 %lhsbool7, label %lor.end, label %lor.rhs

then:                                             ; preds = %lor.end
  call void @yc_frame_pop()
  ret void

ifcont:                                           ; preds = %lor.end
  %data.addr12 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val13 = load ptr, ptr %data.addr12, align 8
  %index.val14 = load i32, ptr %index2, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %index.val14 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val13, i64 %string.expr.index.addr.idx.i64
  %value.val = load i32, ptr %value3, align 4
  %andtmp = and i32 %value.val, 255
  %assign_trunc = trunc i32 %andtmp to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  call void @yc_frame_pop()
  ret void
}

define %Bytes @std2__bytes__append(%Bytes %b, i32 %value) {
entry:
  %out = alloca %Bytes, align 8
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %value2 = alloca i32, align 4
  store i32 %value, ptr %value2, align 4
  call void @yc_frame_push()
  %b.val = load %Bytes, ptr %b1, align 8
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %addtmp = add i32 %len.val, 1
  %calltmp = call %Bytes @std2__bytes__ensure_cap(%Bytes %b.val, i32 %addtmp)
  store %Bytes %calltmp, ptr %out, align 8
  %data.addr = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %len.addr3 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %len.val4 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val, i64 %string.expr.index.addr.idx.i64
  %value.val = load i32, ptr %value2, align 4
  %andtmp = and i32 %value.val, 255
  %assign_trunc = trunc i32 %andtmp to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  %len.addr5 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %compound.member.current = load i32, ptr %len.addr5, align 4
  %compound.add = add i32 %compound.member.current, 1
  store i32 %compound.add, ptr %len.addr5, align 4
  %data.addr6 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %len.addr8 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %len.val9 = load i32, ptr %len.addr8, align 4
  %string.expr.index.addr.idx.i6410 = sext i32 %len.val9 to i64
  %string.expr.index.addr11 = getelementptr inbounds i8, ptr %data.val7, i64 %string.expr.index.addr.idx.i6410
  store i8 0, ptr %string.expr.index.addr11, align 1
  %out.val = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val
}

define %Bytes @std2__bytes__reserve(%Bytes %b, i32 %cap) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %cap2 = alloca i32, align 4
  store i32 %cap, ptr %cap2, align 4
  call void @yc_frame_push()
  %cap.val = load i32, ptr %cap2, align 4
  %cmptmp = icmp slt i32 %cap.val, 0
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %calltmp = call %Bytes @std2__bytes__invalid()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp

ifcont:                                           ; preds = %entry
  %b.val = load %Bytes, ptr %b1, align 8
  %cap.val3 = load i32, ptr %cap2, align 4
  %calltmp4 = call %Bytes @std2__bytes__ensure_cap(%Bytes %b.val, i32 %cap.val3)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp4
}

define %Bytes @std2__bytes__clear(%Bytes %b) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp ne ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  %data.addr2 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val3 = load ptr, ptr %data.addr2, align 8
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val3, i64 0
  store i8 0, ptr %string.expr.index.addr, align 1
  br label %ifcont

ifcont:                                           ; preds = %then, %entry
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  store i32 0, ptr %len.addr, align 4
  %b.val = load %Bytes, ptr %b1, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %b.val
}

define %Bytes @std2__bytes__append_string(%Bytes %b, ptr %text) {
entry:
  %i = alloca i32, align 4
  %out = alloca %Bytes, align 8
  %n = alloca i32, align 4
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %text2 = alloca ptr, align 8
  store ptr %text, ptr %text2, align 8
  call void @yc_frame_push()
  %text.val = load ptr, ptr %text2, align 8
  %calltmp = call i32 @std2__bytes__strlen_local(ptr %text.val)
  store i32 %calltmp, ptr %n, align 4
  %b.val = load %Bytes, ptr %b1, align 8
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %n.val = load i32, ptr %n, align 4
  %addtmp = add i32 %len.val, %n.val
  %calltmp3 = call %Bytes @std2__bytes__ensure_cap(%Bytes %b.val, i32 %addtmp)
  store %Bytes %calltmp3, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %n.val4 = load i32, ptr %n, align 4
  %cmptmp = icmp slt i32 %i.val, %n.val4
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %len.addr5 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %len.val6 = load i32, ptr %len.addr5, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %len.val6 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val, i64 %string.expr.index.addr.idx.i64
  %text.val7 = load ptr, ptr %text2, align 8
  %i.val8 = load i32, ptr %i, align 4
  %string.local.ptr = load ptr, ptr %text2, align 8
  %string.index.ptr.idx.i64 = sext i32 %i.val8 to i64
  %string.index.ptr = getelementptr inbounds i8, ptr %string.local.ptr, i64 %string.index.ptr.idx.i64
  %string.index.load = load i8, ptr %string.index.ptr, align 1
  %string.index.i32 = zext i8 %string.index.load to i32
  %assign_trunc = trunc i32 %string.index.i32 to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  %len.addr9 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %compound.member.current = load i32, ptr %len.addr9, align 4
  %compound.add = add i32 %compound.member.current, 1
  store i32 %compound.add, ptr %len.addr9, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %data.addr10 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val11 = load ptr, ptr %data.addr10, align 8
  %len.addr12 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %len.val13 = load i32, ptr %len.addr12, align 4
  %string.expr.index.addr.idx.i6414 = sext i32 %len.val13 to i64
  %string.expr.index.addr15 = getelementptr inbounds i8, ptr %data.val11, i64 %string.expr.index.addr.idx.i6414
  store i8 0, ptr %string.expr.index.addr15, align 1
  %out.val = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val
}

define %Bytes @std2__bytes__concat(%Bytes %a, %Bytes %b) {
entry:
  %j = alloca i32, align 4
  %i = alloca i32, align 4
  %out = alloca %Bytes, align 8
  %a1 = alloca %Bytes, align 8
  store %Bytes %a, ptr %a1, align 8
  %b2 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b2, align 8
  call void @yc_frame_push()
  %len.addr = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %len.addr3 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %addtmp = add i32 %len.val, %len.val4
  %calltmp = call %Bytes @std2__bytes__new(i32 %addtmp)
  store %Bytes %calltmp, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %len.addr5 = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 2
  %len.val6 = load i32, ptr %len.addr5, align 4
  %cmptmp = icmp slt i32 %i.val, %len.val6
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %out.val = load %Bytes, ptr %out, align 8
  %a.val = load %Bytes, ptr %a1, align 8
  %i.val7 = load i32, ptr %i, align 4
  %calltmp8 = call i32 @std2__bytes__get(%Bytes %a.val, i32 %i.val7)
  %calltmp9 = call %Bytes @std2__bytes__append(%Bytes %out.val, i32 %calltmp8)
  store %Bytes %calltmp9, ptr %out, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  store i32 0, ptr %j, align 4
  br label %for.cond10

for.cond10:                                       ; preds = %for.inc12, %for.after
  %j.val = load i32, ptr %j, align 4
  %len.addr14 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 2
  %len.val15 = load i32, ptr %len.addr14, align 4
  %cmptmp16 = icmp slt i32 %j.val, %len.val15
  %1 = zext i1 %cmptmp16 to i32
  %forcond17 = icmp ne i32 %1, 0
  br i1 %forcond17, label %for.body11, label %for.after13

for.body11:                                       ; preds = %for.cond10
  %out.val18 = load %Bytes, ptr %out, align 8
  %b.val = load %Bytes, ptr %b2, align 8
  %j.val19 = load i32, ptr %j, align 4
  %calltmp20 = call i32 @std2__bytes__get(%Bytes %b.val, i32 %j.val19)
  %calltmp21 = call %Bytes @std2__bytes__append(%Bytes %out.val18, i32 %calltmp20)
  store %Bytes %calltmp21, ptr %out, align 8
  br label %for.inc12

for.inc12:                                        ; preds = %for.body11
  %post_old22 = load i32, ptr %j, align 4
  %post_inc23 = add i32 %post_old22, 1
  store i32 %post_inc23, ptr %j, align 4
  br label %for.cond10

for.after13:                                      ; preds = %for.cond10
  %out.val24 = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val24
}

define %Bytes @std2__bytes__slice(%Bytes %b, i32 %start, i32 %count) {
entry:
  %i = alloca i32, align 4
  %out = alloca %Bytes, align 8
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %start2 = alloca i32, align 4
  store i32 %start, ptr %start2, align 4
  %count3 = alloca i32, align 4
  store i32 %count, ptr %count3, align 4
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %lhsbool = icmp ne i32 %0, 0
  br i1 %lhsbool, label %lor.end7, label %lor.rhs6

lor.rhs:                                          ; preds = %lor.end5
  %start.val14 = load i32, ptr %start2, align 4
  %count.val15 = load i32, ptr %count3, align 4
  %addtmp = add i32 %start.val14, %count.val15
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp16 = icmp sgt i32 %addtmp, %len.val
  %1 = zext i1 %cmptmp16 to i32
  %rhsbool17 = icmp ne i32 %1, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %lor.end5
  %lortmp18 = phi i1 [ true, %lor.end5 ], [ %rhsbool17, %lor.rhs ]
  %2 = zext i1 %lortmp18 to i32
  %ifcond = icmp ne i32 %2, 0
  br i1 %ifcond, label %then, label %ifcont

lor.rhs4:                                         ; preds = %lor.end7
  %count.val = load i32, ptr %count3, align 4
  %cmptmp10 = icmp slt i32 %count.val, 0
  %3 = zext i1 %cmptmp10 to i32
  %rhsbool11 = icmp ne i32 %3, 0
  br label %lor.end5

lor.end5:                                         ; preds = %lor.rhs4, %lor.end7
  %lortmp12 = phi i1 [ true, %lor.end7 ], [ %rhsbool11, %lor.rhs4 ]
  %4 = zext i1 %lortmp12 to i32
  %lhsbool13 = icmp ne i32 %4, 0
  br i1 %lhsbool13, label %lor.end, label %lor.rhs

lor.rhs6:                                         ; preds = %entry
  %start.val = load i32, ptr %start2, align 4
  %cmptmp8 = icmp slt i32 %start.val, 0
  %5 = zext i1 %cmptmp8 to i32
  %rhsbool = icmp ne i32 %5, 0
  br label %lor.end7

lor.end7:                                         ; preds = %lor.rhs6, %entry
  %lortmp = phi i1 [ true, %entry ], [ %rhsbool, %lor.rhs6 ]
  %6 = zext i1 %lortmp to i32
  %lhsbool9 = icmp ne i32 %6, 0
  br i1 %lhsbool9, label %lor.end5, label %lor.rhs4

then:                                             ; preds = %lor.end
  %calltmp = call %Bytes @std2__bytes__invalid()
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp

ifcont:                                           ; preds = %lor.end
  %count.val19 = load i32, ptr %count3, align 4
  %calltmp20 = call %Bytes @std2__bytes__new(i32 %count.val19)
  store %Bytes %calltmp20, ptr %out, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %count.val21 = load i32, ptr %count3, align 4
  %cmptmp22 = icmp slt i32 %i.val, %count.val21
  %7 = zext i1 %cmptmp22 to i32
  %forcond = icmp ne i32 %7, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr23 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 1
  %data.val24 = load ptr, ptr %data.addr23, align 8
  %i.val25 = load i32, ptr %i, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %i.val25 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val24, i64 %string.expr.index.addr.idx.i64
  %data.addr26 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val27 = load ptr, ptr %data.addr26, align 8
  %start.val28 = load i32, ptr %start2, align 4
  %i.val29 = load i32, ptr %i, align 4
  %addtmp30 = add i32 %start.val28, %i.val29
  %string.expr.index.ptr.idx.i64 = sext i32 %addtmp30 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val27, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %assign_trunc = trunc i32 %string.expr.index.i32 to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  %len.addr31 = getelementptr inbounds %Bytes, ptr %out, i32 0, i32 2
  %count.val32 = load i32, ptr %count3, align 4
  store i32 %count.val32, ptr %len.addr31, align 4
  %out.val = load %Bytes, ptr %out, align 8
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %out.val
}

define %Bytes @std2__bytes__clone(%Bytes %b) {
entry:
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  call void @yc_frame_push()
  %b.val = load %Bytes, ptr %b1, align 8
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %calltmp = call %Bytes @std2__bytes__slice(%Bytes %b.val, i32 0, i32 %len.val)
  call void @yc_move_frame_to_parent()
  call void @yc_frame_pop()
  ret %Bytes %calltmp
}

define i1 @std2__bytes__eq(%Bytes %a, %Bytes %b) {
entry:
  %i = alloca i32, align 4
  %a1 = alloca %Bytes, align 8
  store %Bytes %a, ptr %a1, align 8
  %b2 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b2, align 8
  call void @yc_frame_push()
  %len.addr = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %len.addr3 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %cmptmp = icmp ne i32 %len.val, %len.val4
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  %data.addr = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp5 = icmp eq ptr %data.val, null
  %1 = zext i1 %cmptmp5 to i32
  %lhsbool = icmp ne i32 %1, 0
  br i1 %lhsbool, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %ifcont
  %data.addr6 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 1
  %data.val7 = load ptr, ptr %data.addr6, align 8
  %cmptmp8 = icmp eq ptr %data.val7, null
  %2 = zext i1 %cmptmp8 to i32
  %rhsbool = icmp ne i32 %2, 0
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %ifcont
  %lortmp = phi i1 [ true, %ifcont ], [ %rhsbool, %lor.rhs ]
  %3 = zext i1 %lortmp to i32
  %ifcond9 = icmp ne i32 %3, 0
  br i1 %ifcond9, label %then10, label %ifcont16

then10:                                           ; preds = %lor.end
  %data.addr11 = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 1
  %data.val12 = load ptr, ptr %data.addr11, align 8
  %data.addr13 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 1
  %data.val14 = load ptr, ptr %data.addr13, align 8
  %cmptmp15 = icmp eq ptr %data.val12, %data.val14
  %4 = zext i1 %cmptmp15 to i32
  %return.intcast = trunc i32 %4 to i1
  call void @yc_frame_pop()
  ret i1 %return.intcast

ifcont16:                                         ; preds = %lor.end
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont16
  %i.val = load i32, ptr %i, align 4
  %len.addr17 = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 2
  %len.val18 = load i32, ptr %len.addr17, align 4
  %cmptmp19 = icmp slt i32 %i.val, %len.val18
  %5 = zext i1 %cmptmp19 to i32
  %forcond = icmp ne i32 %5, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr20 = getelementptr inbounds %Bytes, ptr %a1, i32 0, i32 1
  %data.val21 = load ptr, ptr %data.addr20, align 8
  %i.val22 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i64 = sext i32 %i.val22 to i64
  %string.expr.index.ptr = getelementptr inbounds i8, ptr %data.val21, i64 %string.expr.index.ptr.idx.i64
  %string.expr.index.load = load i8, ptr %string.expr.index.ptr, align 1
  %string.expr.index.i32 = zext i8 %string.expr.index.load to i32
  %andtmp = and i32 %string.expr.index.i32, 255
  %data.addr23 = getelementptr inbounds %Bytes, ptr %b2, i32 0, i32 1
  %data.val24 = load ptr, ptr %data.addr23, align 8
  %i.val25 = load i32, ptr %i, align 4
  %string.expr.index.ptr.idx.i6426 = sext i32 %i.val25 to i64
  %string.expr.index.ptr27 = getelementptr inbounds i8, ptr %data.val24, i64 %string.expr.index.ptr.idx.i6426
  %string.expr.index.load28 = load i8, ptr %string.expr.index.ptr27, align 1
  %string.expr.index.i3229 = zext i8 %string.expr.index.load28 to i32
  %andtmp30 = and i32 %string.expr.index.i3229, 255
  %cmptmp31 = icmp ne i32 %andtmp, %andtmp30
  %6 = zext i1 %cmptmp31 to i32
  %ifcond32 = icmp ne i32 %6, 0
  br i1 %ifcond32, label %then33, label %ifcont34

for.inc:                                          ; preds = %ifcont34
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then33:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont34:                                         ; preds = %for.body
  br label %for.inc
}

define i1 @std2__bytes__starts_with(%Bytes %b, %Bytes %prefix) {
entry:
  %i = alloca i32, align 4
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %prefix2 = alloca %Bytes, align 8
  store %Bytes %prefix, ptr %prefix2, align 8
  call void @yc_frame_push()
  %len.addr = getelementptr inbounds %Bytes, ptr %prefix2, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %len.addr3 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val4 = load i32, ptr %len.addr3, align 4
  %cmptmp = icmp sgt i32 %len.val, %len.val4
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret i1 false

ifcont:                                           ; preds = %entry
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %len.addr5 = getelementptr inbounds %Bytes, ptr %prefix2, i32 0, i32 2
  %len.val6 = load i32, ptr %len.addr5, align 4
  %cmptmp7 = icmp slt i32 %i.val, %len.val6
  %1 = zext i1 %cmptmp7 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %b.val = load %Bytes, ptr %b1, align 8
  %i.val8 = load i32, ptr %i, align 4
  %calltmp = call i32 @std2__bytes__get(%Bytes %b.val, i32 %i.val8)
  %prefix.val = load %Bytes, ptr %prefix2, align 8
  %i.val9 = load i32, ptr %i, align 4
  %calltmp10 = call i32 @std2__bytes__get(%Bytes %prefix.val, i32 %i.val9)
  %cmptmp11 = icmp ne i32 %calltmp, %calltmp10
  %2 = zext i1 %cmptmp11 to i32
  %ifcond12 = icmp ne i32 %2, 0
  br i1 %ifcond12, label %then13, label %ifcont14

for.inc:                                          ; preds = %ifcont14
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i1 true

then13:                                           ; preds = %for.body
  call void @yc_frame_pop()
  ret i1 false

ifcont14:                                         ; preds = %for.body
  br label %for.inc
}

define i32 @std2__bytes__index_of_byte(%Bytes %b, i32 %value) {
entry:
  %i = alloca i32, align 4
  %needle = alloca i32, align 4
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %value2 = alloca i32, align 4
  store i32 %value, ptr %value2, align 4
  call void @yc_frame_push()
  %value.val = load i32, ptr %value2, align 4
  %andtmp = and i32 %value.val, 255
  store i32 %andtmp, ptr %needle, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.val = load i32, ptr %i, align 4
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp = icmp slt i32 %i.val, %len.val
  %0 = zext i1 %cmptmp to i32
  %forcond = icmp ne i32 %0, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %b.val = load %Bytes, ptr %b1, align 8
  %i.val3 = load i32, ptr %i, align 4
  %calltmp = call i32 @std2__bytes__get(%Bytes %b.val, i32 %i.val3)
  %needle.val = load i32, ptr %needle, align 4
  %cmptmp4 = icmp eq i32 %calltmp, %needle.val
  %1 = zext i1 %cmptmp4 to i32
  %ifcond = icmp ne i32 %1, 0
  br i1 %ifcond, label %then, label %ifcont

for.inc:                                          ; preds = %ifcont
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret i32 -1

then:                                             ; preds = %for.body
  %i.val5 = load i32, ptr %i, align 4
  call void @yc_frame_pop()
  ret i32 %i.val5

ifcont:                                           ; preds = %for.body
  br label %for.inc
}

define void @std2__bytes__fill(%Bytes %b, i32 %value) {
entry:
  %i = alloca i32, align 4
  %fill_value = alloca i32, align 4
  %b1 = alloca %Bytes, align 8
  store %Bytes %b, ptr %b1, align 8
  %value2 = alloca i32, align 4
  store i32 %value, ptr %value2, align 4
  call void @yc_frame_push()
  %data.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val = load ptr, ptr %data.addr, align 8
  %cmptmp = icmp eq ptr %data.val, null
  %0 = zext i1 %cmptmp to i32
  %ifcond = icmp ne i32 %0, 0
  br i1 %ifcond, label %then, label %ifcont

then:                                             ; preds = %entry
  call void @yc_frame_pop()
  ret void

ifcont:                                           ; preds = %entry
  %value.val = load i32, ptr %value2, align 4
  %andtmp = and i32 %value.val, 255
  store i32 %andtmp, ptr %fill_value, align 4
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %ifcont
  %i.val = load i32, ptr %i, align 4
  %len.addr = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 2
  %len.val = load i32, ptr %len.addr, align 4
  %cmptmp3 = icmp slt i32 %i.val, %len.val
  %1 = zext i1 %cmptmp3 to i32
  %forcond = icmp ne i32 %1, 0
  br i1 %forcond, label %for.body, label %for.after

for.body:                                         ; preds = %for.cond
  %data.addr4 = getelementptr inbounds %Bytes, ptr %b1, i32 0, i32 1
  %data.val5 = load ptr, ptr %data.addr4, align 8
  %i.val6 = load i32, ptr %i, align 4
  %string.expr.index.addr.idx.i64 = sext i32 %i.val6 to i64
  %string.expr.index.addr = getelementptr inbounds i8, ptr %data.val5, i64 %string.expr.index.addr.idx.i64
  %fill_value.val = load i32, ptr %fill_value, align 4
  %assign_trunc = trunc i32 %fill_value.val to i8
  store i8 %assign_trunc, ptr %string.expr.index.addr, align 1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %post_old = load i32, ptr %i, align 4
  %post_inc = add i32 %post_old, 1
  store i32 %post_inc, ptr %i, align 4
  br label %for.cond

for.after:                                        ; preds = %for.cond
  call void @yc_frame_pop()
  ret void
}

declare void @yc_frame_push()

declare void @yc_frame_pop()

declare void @yc_runtime_init()

declare i32 @printf(ptr, ...)

declare void @yc_runtime_shutdown()

declare ptr @yc_move_to_parent(ptr)

declare void @yc_move_frame_to_parent()
