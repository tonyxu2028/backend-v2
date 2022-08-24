<template>
  <div class="meedu-main-body" v-loading="loading">
    <back-bar class="mb-30" title="微信小程序"></back-bar>
    <div class="float-left">
      <el-form ref="form" label-width="205px">
        <el-form-item label="AppId">
          <div class="j-flex flex-column" style="margin-left: 3px">
            <div>
              <el-input
                class="w-200px"
                v-model="
                  form.config['meedu.addons.TemplateOne.wechat_mini.app_id']
                "
              >
              </el-input>
            </div>
          </div>
        </el-form-item>

        <el-form-item label="AppSecret">
          <div class="j-flex flex-column" style="margin-left: 3px">
            <div>
              <el-input
                class="w-200px"
                v-model="
                  form.config['meedu.addons.TemplateOne.wechat_mini.secret']
                "
              >
              </el-input>
            </div>
          </div>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>
<script>
import { mapState } from "vuex";
export default {
  data() {
    return {
      key: "微信小程序",
      config: null,
      loading: false,
      renderComponent: true,
      form: {
        config: {
          "meedu.addons.TemplateOne.wechat_mini.app_id": null,
          "meedu.addons.TemplateOne.wechat_mini.secret": null,
        },
      },
      upload: {
        loading: false,
      },
    };
  },
  computed: {
    ...mapState(["enabledAddons"]),
  },
  mounted() {
    this.getConfig();
  },
  methods: {
    getConfig() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.config = null;
      this.$api.System.Config.All().then((res) => {
        let configData = res.data["微信小程序"];
        for (let index in configData) {
          if (
            configData[index].key ===
            "meedu.addons.TemplateOne.wechat_mini.app_id"
          ) {
            this.form.config["meedu.addons.TemplateOne.wechat_mini.app_id"] =
              configData[index].value;
          } else if (
            configData[index].key ===
            "meedu.addons.TemplateOne.wechat_mini.secret"
          ) {
            this.form.config["meedu.addons.TemplateOne.wechat_mini.secret"] =
              configData[index].value;
          }
        }

        setTimeout(() => {
          this.loading = false;
        }, 500);
      });
    },
    save() {
      if (this.loading) {
        return;
      }
      this.loading = true;

      this.$api.System.Config.Save(this.form).then(() => {
        this.$message.success(this.$t("common.success"));
        this.loading = false;

        this.getConfig();
      });
    },
  },
};
</script>
<style lang="less" scoped>
.el-form-item {
  margin-bottom: 30px !important;
}
.meedu-main-body {
  width: 100%;
}
.title {
  width: 100%;
  height: 16px;
  border-left: 4px solid #3ca7fa;
  font-size: 14px;
  line-height: 16px;
  font-weight: 600;
  color: #333333;
  padding-left: 10px;
  margin-top: 20px;
  margin-bottom: 30px;
}
</style>
