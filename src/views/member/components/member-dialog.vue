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
              label-width="110px"
            >
              <el-form-item label="学员昵称" prop="nick_name">
                <el-input
                  v-model="form.nick_name"
                  class="w-300px"
                  placeholder="填写学员昵称"
                ></el-input>
              </el-form-item>

              <el-form-item label="学员头像" prop="avatar">
                <upload-image
                  v-model="form.avatar"
                  :width="100"
                  :height="100"
                  name="上传头像"
                  helper="建议尺寸：100x100"
                ></upload-image>
              </el-form-item>

              <el-form-item label="手机号码" prop="mobile">
                <el-input
                  v-model="form.mobile"
                  class="w-300px"
                  placeholder="填写学员登录手机号码"
                ></el-input>
              </el-form-item>

              <el-form-item label="登录密码" :prop="checkPassword">
                <el-input
                  type="password"
                  v-model="form.password"
                  class="w-300px"
                  placeholder="填写学员登录密码"
                ></el-input>
              </el-form-item>

              <el-form-item label="设置会员">
                <el-select class="w-300px" clearable v-model="form.role_id">
                  <el-option
                    v-for="(item, index) in roles"
                    :key="index"
                    :label="item.name"
                    :value="item.id"
                  >
                  </el-option>
                </el-select>
              </el-form-item>

              <el-form-item label="会员到期" v-if="form.role_id">
                <el-date-picker
                  :picker-options="pickerOptions"
                  style="width: 300px"
                  v-model="form.role_expired_at"
                  type="date"
                  placeholder="授权会员到期时间"
                >
                </el-date-picker>
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
        avatar: null,
        nick_name: null,
        mobile: null,
        password: null,
        role_id: null,
        role_expired_at: null,
        is_lock: null,
      },
      rules: {
        avatar: [
          {
            required: true,
            message: "请上传头像",
            trigger: "blur",
          },
        ],
        nick_name: [
          {
            required: true,
            message: "填写学员昵称",
            trigger: "blur",
          },
        ],
        mobile: [
          {
            required: true,
            message: "填写学员登录手机号码",
            trigger: "blur",
          },
        ],
        password: [
          {
            required: true,
            message: "填写学员登录密码",
            trigger: "blur",
          },
        ],
      },
      loading: false,
      roles: [],
      pickerOptions: {
        disabledDate(time) {
          return time.getTime() < Date.now();
        },
      },
    };
  },
  computed: {
    checkPassword() {
      if (this.text === "添加学员资料") {
        return "password";
      }
      return null;
    },
  },
  mounted() {
    this.params();
    this.form.avatar = null;
    this.form.nick_name = null;
    this.form.mobile = null;
    this.form.password = null;
    this.form.role_id = null;
    this.form.role_expired_at = null;
    this.form.is_lock = null;
    if (this.id) {
      this.getDetail();
    }
  },
  methods: {
    params() {
      this.$api.Member.Create().then((res) => {
        this.roles = res.data.roles;
      });
    },
    getDetail() {
      this.$api.Member.Edit(this.id).then((res) => {
        var data = res.data;
        if (data.role_id === 0) {
          data.role_id = null;
        }

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
      if (this.form.role_id && !this.form.role_expired_at) {
        this.$message.error("请输入会员到期时间");
        return;
      }
      this.loading = true;
      if (this.text === "添加学员资料") {
        this.$api.Member.Store(this.form)
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
        this.$api.Member.Update(this.id, this.form)
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
