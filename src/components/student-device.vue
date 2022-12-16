<template>
  <transition name="fade">
    <div class="mask">
      <div class="dialog-box">
        <div class="dialog-header">
          <span>访问学员端</span>
          <img
            class="icon-close"
            @click="close()"
            src="@/assets/img/close.png"
          />
        </div>
        <div class="dialog-body">
          <div id="qrcode" ref="qrcode"></div>
          <label>H5端扫码访问</label>
          <el-button type="primary" @click="goPCDevice()"
            >直接访问PC网校</el-button
          >
        </div>
      </div>
    </div>
  </transition>
</template>
<script>
import QRCode from "qrcodejs2";
import Config from "@/js/config";
export default {
  props: [],
  data() {
    return {
      loading: false,
      pcUrl: null,
      h5Url: null,
    };
  },
  mounted() {
    this.getData();
  },
  beforeDestroy() {},
  methods: {
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.System.Config.All().then((res) => {
        let configData = res.data["系统"];
        for (let index in configData) {
          if (configData[index].key === "meedu.system.pc_url") {
            this.pcUrl = configData[index].value;
          } else if (configData[index].key === "meedu.system.h5_url") {
            this.h5Url = configData[index].value;
            this.$nextTick(() => {
              this.crateQrcode();
            });
          }
        }
        setTimeout(() => {
          this.loading = false;
        }, 500);
      });
    },
    close() {
      this.$emit("close");
    },
    crateQrcode() {
      var qrcode = new QRCode("qrcode", {
        width: 150,
        height: 150, // 高度
        text: this.h5Url, // 二维码内容
      });
    },
    goPCDevice() {
      window.open(this.pcUrl);
    },
  },
};
</script>
<style lang="less" scoped>
.mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 801;
  background-color: rgba(0, 0, 0, 0.5);
}
.dialog-box {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 500px;
  height: 394px;
  background-color: white;
  border-radius: 8px;
  animation: scaleBig 0.3s;
  margin-left: -250px;
  margin-top: -197px;

  .dialog-header {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding: 30px;
    line-height: 18px;
    position: relative;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    span {
      flex: 1;
      font-size: 18px;
      font-weight: 500;
      color: #333333;
      line-height: 20px;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
    }
    .icon-close {
      width: 16.25px;
      height: 16.25px;
      margin-right: 2px;
      margin-top: 2px;
      cursor: pointer;
      &:hover {
        opacity: 0.8;
      }
    }
  }
  .dialog-body {
    width: 100%;
    height: 356px;
    float: left;
    box-sizing: border-box;
    padding: 0px 30px 30px 30px;
    display: flex;
    flex-direction: column;
    align-items: center;
    #qrcode {
      width: 150px;
      height: 150px;
    }
    label {
      font-size: 14px;
      font-weight: 400;
      color: #666666;
      line-height: 14px;
      margin-top: 10px;
      margin-bottom: 50px;
    }
  }
}
</style>
