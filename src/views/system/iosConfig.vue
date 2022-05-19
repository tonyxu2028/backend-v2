<template>
  <div class="meedu-main-body" v-loading="loading">
    <back-bar class="mb-30" title="支付配置"></back-bar>
    <div class="float-left">
      <el-form ref="form" label-width="205px">
        <template v-if="enabledAddons['TemplateOne'] === 1">
          <div class="title">苹果支付</div>
          <el-form-item :key="1918" label="苹果支付DEBUG">
            <div class="j-flex flex-column" style="margin-left: 3px">
              <div>
                <el-switch
                  v-model="
                    form.config['meedu.addons.TemplateOne.apple.pay_debug']
                  "
                  active-value="1"
                  inactive-value="0"
                >
                </el-switch>
              </div>
              <div class="mt-5">
                <div class="form-helper-text">
                  <span
                    >应用开发时使用，正式上线请勿开启。否则将导致充值无法到账。</span
                  >
                </div>
              </div>
            </div>
          </el-form-item>

          <el-form-item :key="1848" label="苹果App BundleID">
            <div class="j-flex flex-column" style="margin-left: 3px">
              <div>
                <el-input
                  class="w-200px"
                  v-model="
                    form.config['meedu.addons.TemplateOne.apple.app_bundle_id']
                  "
                >
                </el-input>
              </div>
            </div>
          </el-form-item>
          <el-form-item :key="1849" label="苹果App虚拟货币名">
            <div class="j-flex flex-column" style="margin-left: 3px">
              <div>
                <el-input
                  class="w-200px"
                  v-model="
                    form.config['meedu.addons.TemplateOne.apple.credit2_name']
                  "
                >
                </el-input>
              </div>
              <div class="mt-5">
                <div class="form-helper-text">
                  <span>请填写1元人民币换算后的虚拟货币数值</span>
                </div>
              </div>
            </div>
          </el-form-item>
          <el-form-item :key="1850" label="苹果App虚拟货币汇率">
            <div class="j-flex flex-column" style="margin-left: 3px">
              <div>
                <el-input
                  class="w-200px"
                  v-model="
                    form.config[
                      'meedu.addons.TemplateOne.apple.credit2_exchange_rate'
                    ]
                  "
                >
                </el-input>
              </div>
              <div class="mt-5">
                <div class="form-helper-text">
                  <span>请填写1元人民币换算后的虚拟货币数值</span>
                </div>
              </div>
            </div>
          </el-form-item>
          <el-form-item :key="1847" label="苹果产品id参数">
            <div class="j-flex flex-column" style="margin-left: 3px">
              <div>
                <el-input
                  class="w-200px"
                  type="textarea"
                  :rows="3"
                  v-model="
                    form.config['meedu.addons.TemplateOne.apple.product_ids']
                  "
                >
                </el-input>
              </div>
            </div>
          </el-form-item>
          <div class="title">IOS开发</div>
          <el-form-item :key="1921" label="苹果IOS-应用key">
            <div class="j-flex flex-column" style="margin-left: 3px">
              <div>
                <el-input
                  class="w-200px"
                  v-model="form.config['meedu.addons.TemplateOne.app.ios_key']"
                >
                </el-input>
              </div>
            </div>
          </el-form-item>
          <el-form-item :key="1922" label="苹果IOS-游客模式">
            <div class="j-flex flex-column" style="margin-left: 3px">
              <div>
                <el-switch
                  v-model="
                    form.config['meedu.addons.TemplateOne.app.ios_free_login']
                  "
                  active-value="1"
                  inactive-value="0"
                >
                </el-switch>
              </div>
            </div>
          </el-form-item>
        </template>
      </el-form>
      <div style="display: none">
        <input type="file" ref="cert-client-file" @change="clientChange" />
        <input type="file" ref="cert-key-file" @change="keyChange" />
      </div>
      <div class="bottom-menus">
        <div class="bottom-menus-box">
          <div>
            <el-button @click="save" :loading="loading" type="primary"
              >保存</el-button
            >
          </div>
          <div class="ml-24">
            <el-button @click="$router.back()">取消</el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { mapState } from "vuex";
export default {
  data() {
    return {
      key: "支付",
      config: null,
      loading: false,
      renderComponent: true,
      form: {
        config: {
          "meedu.addons.TemplateOne.apple.product_ids": null,
          "meedu.addons.TemplateOne.apple.app_bundle_id": null,
          "meedu.addons.TemplateOne.apple.pay_debug": null,
          "meedu.addons.TemplateOne.apple.credit2_name": null,
          "meedu.addons.TemplateOne.apple.credit2_exchange_rate": null,
          "meedu.addons.TemplateOne.app.ios_key": null,
          "meedu.addons.TemplateOne.app.ios_free_login": null,
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
    uploadCertClient() {
      if (this.upload.loading) {
        return;
      }
      this.$refs["cert-client-file"].click();
    },
    uploadKeyClient() {
      if (this.upload.loading) {
        return;
      }
      this.$refs["cert-key-file"].click();
    },
    clientChange(e) {
      if (e.target.files.length === 0) {
        return;
      }
      this.upload.loading = true;
      let file = e.target.files[0];
      // 文件扩展名检测
      let extension = file.name.split(".");
      extension = extension[extension.length - 1];
      if (extension !== "pem") {
        this.$message.error("请选择pem文件");
        return;
      }
      // 读取数据
      let reader = new FileReader();
      reader.readAsText(file);
      reader.onload = (e) => {
        let data = e.target.result;
        this.upload.loading = false;
        this.form.config["pay.wechat.cert_client"] = data;
      };
    },
    keyChange(e) {
      if (e.target.files.length === 0) {
        return;
      }
      this.upload.loading = true;
      let file = e.target.files[0];
      // 文件扩展名检测
      let extension = file.name.split(".");
      extension = extension[extension.length - 1];
      if (extension !== "pem") {
        this.$message.error("请选择pem文件");
        return;
      }
      // 读取数据
      let reader = new FileReader();
      reader.readAsText(file);
      reader.onload = (e) => {
        let data = e.target.result;
        this.upload.loading = false;
        this.form.config["pay.wechat.cert_key"] = data;
      };
    },
    getConfig() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.config = null;
      this.$api.System.Config.All().then((res) => {
        let configData = res.data["立春模板"];
        for (let index in configData) {
          if (
            configData[index].key ===
            "meedu.addons.TemplateOne.apple.product_ids"
          ) {
            this.form.config["meedu.addons.TemplateOne.apple.product_ids"] =
              configData[index].value;
          } else if (
            configData[index].key ===
            "meedu.addons.TemplateOne.apple.app_bundle_id"
          ) {
            this.form.config["meedu.addons.TemplateOne.apple.app_bundle_id"] =
              configData[index].value;
          } else if (
            configData[index].key === "meedu.addons.TemplateOne.apple.pay_debug"
          ) {
            this.form.config["meedu.addons.TemplateOne.apple.pay_debug"] =
              configData[index].value;
          } else if (
            configData[index].key ===
            "meedu.addons.TemplateOne.apple.credit2_name"
          ) {
            this.form.config["meedu.addons.TemplateOne.apple.credit2_name"] =
              configData[index].value;
          } else if (
            configData[index].key ===
            "meedu.addons.TemplateOne.apple.credit2_exchange_rate"
          ) {
            this.form.config[
              "meedu.addons.TemplateOne.apple.credit2_exchange_rate"
            ] = configData[index].value;
          } else if (
            configData[index].key === "meedu.addons.TemplateOne.app.ios_key"
          ) {
            this.form.config["meedu.addons.TemplateOne.app.ios_key"] =
              configData[index].value;
          } else if (
            configData[index].key ===
            "meedu.addons.TemplateOne.app.ios_free_login"
          ) {
            this.form.config["meedu.addons.TemplateOne.app.ios_free_login"] =
              configData[index].value;
          }
        }

        setTimeout(() => {
          this.loading = false;
          this.renderComponent = false;
          this.$nextTick(() => {
            this.renderComponent = true;
          });
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
