<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-cate-dialog-box teacher">
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
              <el-form-item label="讲师名称" prop="name">
                <el-input
                  v-model="form.name"
                  placeholder="填写讲师名称"
                  class="w-300px"
                ></el-input>
              </el-form-item>

              <el-form-item prop="avatar" label="讲师头像">
                <upload-image
                  v-model="form.avatar"
                  helper="长宽比1:1 推荐尺寸200x200"
                  width="100"
                  height="100"
                  name="讲师头像"
                ></upload-image>
              </el-form-item>

              <el-form-item label="登录邮箱" prop="username">
                <div class="d-flex">
                  <div>
                    <el-input
                      v-model="form.username"
                      placeholder="填写讲师登录邮箱"
                      class="w-300px"
                    ></el-input>
                  </div>
                  <div class="ml-10">
                    <helper-text text="用于讲师客户端登录"></helper-text>
                  </div>
                </div>
              </el-form-item>

              <el-form-item label="登录密码" prop="password">
                <div class="d-flex">
                  <div>
                    <el-input
                      v-model="form.password"
                      class="w-300px"
                      placeholder="填写讲师登录密码"
                    ></el-input>
                  </div>
                  <div class="ml-10">
                    <helper-text text="用于讲师客户端登录"></helper-text>
                  </div>
                </div>
              </el-form-item>

              <el-form-item label="讲师风采" prop="short_desc">
                <el-input
                  type="textarea"
                  v-model="form.short_desc"
                  class="w-600px"
                  rows="4"
                  placeholder="填写讲师相关介绍，用于直播课前台展示"
                  resize="none"
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
import UploadImage from "@/components/upload-image";
export default {
  components: {
    UploadImage,
  },
  props: ["id", "text"],
  data() {
    return {
      form: {
        name: null,
        short_desc: null,
        is_hidden: 0,
        username: null,
        password: null,
        avatar: null,
      },
      rules: {
        name: [
          {
            required: true,
            message: "讲师名称不能为空",
            trigger: "blur",
          },
        ],
        short_desc: [
          {
            required: true,
            message: "讲师风采不能为空",
            trigger: "blur",
          },
        ],
        is_hidden: [
          {
            required: true,
            message: "请选择是否隐藏",
            trigger: "blur",
          },
        ],
        password: [
          {
            required: true,
            message: "登录密码不能为空",
            trigger: "blur",
          },
        ],
        username: [
          {
            required: true,
            message: "登录邮箱不能为空",
            trigger: "blur",
          },
        ],
        avatar: [
          {
            required: true,
            message: "请上传讲师头像",
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
    this.form.parent_id = null;
    if (this.id) {
      this.getDetail();
    }
  },
  methods: {
    getDetail() {
      this.$api.Course.Live.Teacher.Detail(this.id).then((res) => {
        var data = res.data;
        this.form = data;
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
      if (this.text === "添加讲师") {
        this.$api.Course.Live.Teacher.Store(this.form)
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
        this.$api.Course.Live.Teacher.Update(this.id, this.form)
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
