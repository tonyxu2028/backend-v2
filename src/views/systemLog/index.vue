<template>
  <div class="meedu-main-body">
    <div class="float-left">
      <el-radio-group v-model="courseTabActive">
        <el-radio-button
          :label="item.key"
          v-for="item in courseTypes"
          :key="item.key"
          >{{ item.name }}</el-radio-button
        >
      </el-radio-group>
    </div>
    <div class="float-left mt-30">
      <admin-log v-if="courseTabActive === 'admin'"></admin-log>
      <user-login-log
        v-else-if="courseTabActive === 'userLogin'"
      ></user-login-log>
      <upload-images-log
        v-else-if="courseTabActive === 'uploadImages'"
      ></upload-images-log>
    </div>
  </div>
</template>
<script>
import { mapState } from "vuex";
import AdminLog from "./components/admin-log.vue";
import UserLoginLog from "./components/user-login-log.vue";
import UploadImagesLog from "./components/upload-images-log.vue";
export default {
  components: {
    AdminLog,
    UserLoginLog,
    UploadImagesLog,
  },
  data() {
    return {
      courseTabActive: "admin",
      loading: false,
    };
  },
  computed: {
    ...mapState(["enabledAddons", "user"]),
    courseTypes() {
      let types = [];

      if (this.checkPermission("system.log.admin")) {
        types.push({
          name: "管理后台日志",
          key: "admin",
        });
      }
      if (this.checkPermission("system.log.userLogin")) {
        types.push({
          name: "学员登录日志",
          key: "userLogin",
        });
      }
      if (this.checkPermission("system.log.uploadImages")) {
        types.push({
          name: "图片上传日志",
          key: "uploadImages",
        });
      }
      return types;
    },
  },
  mounted() {},
  methods: {
    checkPermission(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
  },
};
</script>
<style lang="less" scoped>
.meedu-main-body {
  width: 100%;
  height: auto;
  float: left;
}
</style>
