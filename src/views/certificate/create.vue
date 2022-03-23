<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="新建证书"></back-bar>

    <div class="float-left">
      <el-form
        ref="form"
        :model="course"
        :rules="rules"
        class="float-left"
        label-width="200px"
      >
        <div class="float-left">
          <el-form-item label="证书名" prop="name">
            <div class="d-flex">
              <div>
                <el-input
                  maxlength="64"
                  v-model="course.name"
                  class="w-500px"
                  placeholder="证书名"
                ></el-input>
              </div>
              <div class="ml-10">
                <helper-text text="证书名不得超过64个字符。"></helper-text>
              </div>
            </div>
          </el-form-item>

          <el-form-item prop="template_image" label="证书">
            <upload-image
              v-model="course.template_image"
              width="90"
              height="120"
              name="上传证书"
            ></upload-image>
          </el-form-item>

          <el-form-item
            prop="params"
            label="证书参数"
            v-if="course.template_image"
          >
            <div class="d-flex">
              <el-button @click="showWindow = true">参数配置</el-button>
            </div>
          </el-form-item>
        </div>
      </el-form>

      <div class="bottom-menus">
        <div class="bottom-menus-box">
          <div>
            <el-button @click="formValidate" :loading="loading" type="primary"
              >保存</el-button
            >
          </div>
          <div class="ml-24">
            <el-button @click="$router.back()">取消</el-button>
          </div>
        </div>
      </div>
    </div>
    <certificate-params
      :show="showWindow"
      :image="course.template_image"
      @close="showWindow = false"
      @change="saveParams"
    ></certificate-params>
  </div>
</template>
<script>
import UploadImage from "@/components/upload-image";
import CertificateParams from "@/components/certificate-params";

export default {
  components: {
    UploadImage,
    CertificateParams,
  },
  data() {
    return {
      course: {
        name: null,
        template_image: null,
        params: "",
      },
      rules: {
        name: [
          {
            required: true,
            message: "证书名不能为空",
            trigger: "blur",
          },
        ],
        template_image: [
          {
            required: true,
            message: "请上传证书",
            trigger: "blur",
          },
        ],
        params: [
          {
            required: true,
            message: "证书参数不能为空",
            trigger: "blur",
          },
        ],
      },
      categories: [],
      loading: false,
      showWindow: false,
    };
  },
  mounted() {
    this.params();
  },
  methods: {
    isJSON(str) {
      if (typeof str == "string") {
        try {
          var obj = JSON.parse(str);
          if (typeof obj == "object" && obj) {
            return true;
          } else {
            return false;
          }
        } catch (e) {
          return false;
        }
      }
    },
    params() {
      this.$api.Certificate.Create().then((res) => {});
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
      if (!this.isJSON(this.course.params)) {
        this.$message.error("请输入JSON字符串");
        return;
      }
      this.loading = true;
      this.$api.Certificate.Store(this.course)
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.$router.back();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
    saveParams(val) {
      this.params = val;
      this.showWindow = false;
    },
  },
};
</script>
