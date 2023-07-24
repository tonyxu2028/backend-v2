<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-cate-dialog-box">
        <div class="meedu-dialog-header">{{ text }}</div>
        <div class="meedu-dialog-body">
          <div class="float-left">
            <el-form
              ref="form"
              class="float-left"
              :model="form"
              :rules="rules"
              label-width="100px"
            >
              <el-form-item label="父级分类" prop="parent_id">
                <el-select class="w-300px" clearable v-model="form.parent_id">
                  <el-option
                    v-for="(item, index) in localCategories"
                    :key="index"
                    :label="item.name"
                    :value="item.id"
                  >
                  </el-option>
                </el-select>
              </el-form-item>
              <el-form-item label="分类名称" prop="name">
                <el-input
                  v-model="form.name"
                  class="w-300px"
                  placeholder="填写分类名称"
                ></el-input>
              </el-form-item>

              <el-form-item label="排序" prop="sort">
                <div class="d-flex">
                  <div>
                    <el-input
                      type="number"
                      v-model="form.sort"
                      class="w-300px"
                    ></el-input>
                  </div>
                  <div class="ml-10">
                    <helper-text
                      text="填写整数，数字越小排序越靠前"
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
  </transition>
</template>
<script>
export default {
  props: ["id", "text", "categories"],
  data() {
    return {
      localCategories: [
        {
          id: 0,
          name: "无-作为一级分类",
        },
      ],
      form: {
        sort: null,
        name: null,
        parent_id: 0,
      },
      rules: {
        sort: [
          {
            required: true,
            message: "排序不能为空",
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
        parent_id: [
          {
            required: true,
            message: "请选择父级分类",
            trigger: "blur",
          },
        ],
      },
      loading: false,
    };
  },
  mounted() {
    this.form.name = null;
    this.form.sort = null;
    this.form.parent_id = 0;
    if (this.id) {
      this.getDetail();
    } else {
      this.localCategories = this.localCategories.concat(this.categories);
    }
  },
  methods: {
    getDetail() {
      this.$api.Course.LearnPath.Path.Category.Detail(this.id).then((res) => {
        var data = res.data;
        this.form.name = data.name;
        this.form.sort = data.sort;
        this.form.parent_id = data.parent_id;
        let categories = this.categories;
        let new_arr = [
          {
            id: 0,
            name: "无-作为一级分类",
          },
        ];
        for (let i = 0; i < categories.length; i++) {
          if (categories[i].id !== data.id) {
            new_arr.push(categories[i]);
          }
        }
        this.localCategories = new_arr;
      });
    },
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
      if (this.loading) {
        return;
      }
      this.loading = true;
      if (this.text === "添加分类") {
        this.$api.Course.LearnPath.Path.Category.Store(this.form)
          .then(() => {
            this.loading = false;
            this.$message.success(this.$t("common.success"));
            this.$emit("success");
          })
          .catch((e) => {
            this.loading = false;
            this.$message.error(e.message);
          });
      } else {
        this.$api.Course.LearnPath.Path.Category.Update(this.id, this.form)
          .then(() => {
            this.loading = false;
            this.$message.success(this.$t("common.success"));
            this.$emit("success");
          })
          .catch((e) => {
            this.loading = false;
            this.$message.error(e.message);
          });
      }
    },
  },
};
</script>
