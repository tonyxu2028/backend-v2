<template>
  <div class="meedu-dialog-mask" v-if="show">
    <div class="meedu-dialog-box">
      <div class="meedu-dialog-header">{{ text }}</div>
      <div class="meedu-dialog-body">
        <div class="float-left">
          <el-form
            ref="form"
            class="float-left"
            :model="form"
            :rules="rules"
            label-width="200px"
          >
            <el-form-item label="父级分类" prop="parent_id">
              <el-select v-model="form.parent_id">
                <el-option
                  v-for="(item, index) in categories"
                  :key="index"
                  :label="item.name"
                  :value="item.id"
                >
                </el-option>
              </el-select>
            </el-form-item>

            <el-form-item label="分类名称" prop="name">
              <el-input v-model="form.name" class="w-200px"></el-input>
            </el-form-item>

            <el-form-item label="排序" prop="sort">
              <div class="d-flex">
                <div>
                  <el-input
                    type="number"
                    v-model="form.sort"
                    class="w-200px"
                  ></el-input>
                </div>
                <div class="ml-10">
                  <helper-text
                    text="请输入整数。小数排在前面，大数排在后面。"
                  ></helper-text>
                </div>
              </div>
            </el-form-item>
          </el-form>
        </div>
      </div>
      <div class="meedu-dialog-footer">
        <el-button @click="formValidate" :loading="loading" type="primary">
          保存
        </el-button>
        <el-button @click="close"> 取消 </el-button>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  props: ["show", "text", "categories"],
  data() {
    return {
      form: {
        sort: null,
        name: null,
        parent_id: null,
      },
      rules: {
        sort: [
          {
            required: true,
            message: "升序不能为空",
            trigger: "blur",
          },
        ],
        name: [
          {
            required: true,
            message: "分类名称不能为空",
            trigger: "blur",
          },
        ],
      },
      loading: false,
    };
  },
  mounted() {},
  methods: {
    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.confirm();
        }
      });
    },
    close() {
      this.$emit("close");
    },
    confirm() {
      this.$emit("confirm", this.form);
    },
  },
};
</script>
