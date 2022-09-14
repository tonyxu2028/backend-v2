<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-dialog-box">
        <div class="meedu-dialog-header">编辑友情链接</div>
        <div class="meedu-dialog-body">
          <el-form ref="form" :model="form" :rules="rules" label-width="200px">
            <el-form-item prop="sort" label="排序值">
              <div class="d-flex">
                <div>
                  <el-input v-model="form.sort" class="w-200px"></el-input>
                </div>
                <div class="ml-10">
                  <helper-text
                    text="填写整数，数字越小排序越靠前"
                  ></helper-text>
                </div>
              </div>
            </el-form-item>

            <el-form-item label="链接名" prop="name">
              <el-input v-model="form.name" class="w-200px"></el-input>
            </el-form-item>

            <el-form-item label="链接地址" prop="url">
              <el-input v-model="form.url" class="w-200px"></el-input>
            </el-form-item>
          </el-form>
        </div>
        <div class="meedu-dialog-footer">
          <el-button type="primary" @click="formValidate" :loading="loading">
            确定
          </el-button>
          <el-button @click="close" class="ml-30">取消</el-button>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  props: ["id"],
  data() {
    return {
      loading: false,
      showLinkWin: false,
      form: {
        sort: null,
        name: null,
        url: null,
      },
      parentNavs: [],
      rules: {
        sort: [
          {
            required: true,
            message: "请输入排序数值",
            trigger: "blur",
          },
        ],
        name: [
          {
            required: true,
            message: "请输入链接名",
            trigger: "blur",
          },
        ],
        url: [
          {
            required: true,
            message: "请输入链接地址",
            trigger: "blur",
          },
        ],
      },
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    getData() {
      this.$api.System.Links.Detail(this.id).then((res) => {
        this.form = res.data;
      });
    },
    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.confirm();
        }
      });
    },
    confirm() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.System.Links.Update(this.id, this.form)
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.$emit("close");
        })
        .catch((e) => {
          this.$message.error(e.message);
        });
    },
    close() {
      this.$emit("close");
    },
    linkChange(link) {
      this.form.url = link.url;
      this.showLinkWin = false;
    },
  },
};
</script>
