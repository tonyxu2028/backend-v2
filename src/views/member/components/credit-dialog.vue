<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-cate-dialog-box">
        <div class="meedu-dialog-header">积分变动</div>
        <div class="meedu-dialog-body">
          <div class="float-left">
            <el-form
              ref="form"
              class="float-left"
              :model="form"
              :rules="rules"
              label-width="110px"
            >
              <el-form-item label="变动额度" prop="credit1">
                <div class="d-flex">
                  <div>
                    <el-input
                      v-model="form.credit1"
                      class="w-300px"
                      placeholder="请输入变动额度"
                    ></el-input>
                  </div>
                  <div class="ml-10">
                    <helper-text
                      text="正数增加积分，负数减少积分"
                    ></helper-text>
                  </div>
                </div>
              </el-form-item>

              <el-form-item label="变动说明" prop="remark">
                <el-input
                  type="textarea"
                  v-model="form.remark"
                  class="w-300px"
                  placeholder="请输入变动说明"
                ></el-input>
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
  props: ["id"],
  data() {
    return {
      form: {
        credit1: null,
        remark: null,
      },
      rules: {
        credit1: [
          {
            required: true,
            message: "请输入变动额度",
            trigger: "blur",
          },
        ],
        remark: [
          {
            required: true,
            message: "请输入变动说明",
            trigger: "blur",
          },
        ],
      },
      loading: false,
    };
  },
  mounted() {
    this.form.credit1 = null;
    this.form.remark = null;
  },
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
      if (this.loading) {
        return;
      }
      this.loading = true;
      let data = { user_id: this.id };
      Object.assign(data, this.form);
      this.$api.Member.Credit1Change(data)
        .then(() => {
          this.loading = false;
          this.$message.success(this.$t("common.success"));
          this.$emit("success");
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
  },
};
</script>
