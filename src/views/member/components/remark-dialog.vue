<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-cate-dialog-box">
        <div class="meedu-dialog-header">修改备注</div>
        <div class="meedu-dialog-body">
          <div class="float-left">
            <el-form
              ref="form"
              class="float-left"
              :model="form"
              :rules="rules"
              label-width="110px"
            >
              <el-form-item label="学员备注" prop="remark">
                <div class="w-600px">
                  <quill-editor
                    v-if="renderComponent"
                    v-model="form.remark"
                    :height="200"
                  ></quill-editor>
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
import QuillEditor from "@/components/quill-editor";
export default {
  components: {
    QuillEditor,
  },
  props: ["id"],
  data() {
    return {
      form: {
        remark: null,
      },
      rules: {
        remark: [
          {
            required: true,
            message: "请输入变动说明",
            trigger: "blur",
          },
        ],
      },
      loading: false,
      renderComponent: true,
    };
  },
  watch: {
    "form.remark"() {
      this.renderComponent = false;
      this.$nextTick(() => {
        this.renderComponent = true;
      });
    },
  },
  mounted() {
    this.form.remark = null;
    if (this.id) {
      this.getUser();
    }
  },
  methods: {
    getUser() {
      this.$api.Member.Edit(this.id).then((res) => {
        this.form.remark = res.data.remark ? res.data.remark.remark : null;
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
      this.$api.Member.RemarkUpdate(this.id, this.form)
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
