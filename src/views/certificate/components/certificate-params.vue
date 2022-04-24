<template>
  <div class="certificate-box-mask" v-if="show">
    <div class="certificate-content">
      <div class="certificate-content-title">证书参数配置</div>
      <div class="certificate-box">
        <div class="certificate-blocks-box">
          <div class="title">拖动添加板块</div>
          <div class="tip">拖动下列图标到右侧预览区</div>
          <draggable
            class="blocks"
            :sort="false"
            :group="{ name: 'blocks', pull: 'clone', put: false }"
          >
            <div class="block-item" sign="text-v1">
              <div class="btn">
                <div class="icon">
                  <img
                    src="@/assets/images/decoration/h5/h5-vod-v1.png"
                    width="44"
                    height="44"
                  />
                </div>
                <div class="name">文本</div>
              </div>
            </div>
            <div class="block-item" sign="image-v1">
              <div class="btn">
                <div class="icon">
                  <img
                    src="@/assets/images/decoration/h5/h5-topic-v1.png"
                    width="44"
                    height="44"
                  />
                </div>
                <div class="name">图片</div>
              </div>
            </div>
            <div class="block-item" sign="qrcode-v1">
              <div class="btn">
                <div class="icon">
                  <img
                    src="@/assets/images/decoration/h5/code.png"
                    width="44"
                    height="44"
                  />
                </div>
                <div class="name">二维码</div>
              </div>
            </div>
          </draggable>
        </div>
        <draggable
          ref="preview-box"
          class="certificate-preview-box"
          draggable=".block-item"
          group="blocks"
          @add="dragChange"
        >
          <div class="image-box">
            <div class="image-render">
              <img ref="previewImage" class="image" :src="image" />
            </div>
            <template v-for="(item, index) in blocksData">
              <div
                :key="item.id"
                class="item"
                :class="{ active: curBlockIndex === index }"
                @click="curBlockIndex = index"
                :style="{
                  top: item.config.y + 'px',
                  left: item.config.x + 'px',
                }"
              >
                <render-text-v1
                  v-if="item.sign === 'text-v1'"
                  :current="index"
                  :config="item.config"
                  @dragend="changePosition"
                ></render-text-v1>
                <render-image-v1
                  v-if="item.sign === 'image-v1'"
                  :current="index"
                  :config="item.config"
                  @dragend="changePosition"
                ></render-image-v1>
                <render-qrcode-v1
                  v-if="item.sign === 'qrcode-v1'"
                  :current="index"
                  :config="item.config"
                  :status="qrcodeStatus"
                  @dragend="changePosition"
                ></render-qrcode-v1>

                <div class="item-options" v-if="curBlockIndex === index">
                  <div class="btn-item" @click="blockDestroy(index)">
                    <i class="el-icon-delete-solid"></i>
                  </div>
                </div>
              </div>
            </template>
          </div>
        </draggable>
        <div class="certificate-config-box" v-if="curBlockIndex !== null">
          <div class="float-left mb-15">
            <el-button class="ml-15 mt-15" @click="curBlockIndex = null">
              <i class="el-icon-close"></i><span class="ml-5">关闭配置</span>
            </el-button>
          </div>
          <config-setting
            :block="blocksData[curBlockIndex]"
            :index="curBlockIndex"
            @create="createQrcode"
          ></config-setting>
        </div>
      </div>
      <div class="certificate-content-footer">
        <el-button class="footer_btn" type="primary" @click="confirm">
          确定
        </el-button>
        <el-button class="footer_btn ml-30" @click="close"> 取消 </el-button>
      </div>
    </div>
  </div>
</template>
<script>
import draggable from "vuedraggable";
import ConfigSetting from "./certificate-config.vue";
import RenderTextV1 from "../render/text-v1.vue";
import RenderImageV1 from "../render/image-v1.vue";
import RenderQrcodeV1 from "../render/qrcode-v1.vue";
export default {
  components: {
    draggable,
    ConfigSetting,
    RenderTextV1,
    RenderImageV1,
    RenderQrcodeV1,
  },
  props: ["show", "image"],
  data() {
    return {
      loading: false,
      params: "",
      blocksData: [],
      curBlockIndex: null,
      qrcodeStatus: null,
    };
  },
  mounted() {},
  methods: {
    changePosition(sign, index, moveX, moveY) {
      let previewImage = this.$refs.previewImage;
      for (let i = 0; i < this.blocksData.length; i++) {
        if (this.blocksData[i].sign === sign && i === index) {
          let mx = this.blocksData[i].config.x + moveX;
          let my = this.blocksData[i].config.y + moveY;
          let maxHeight;
          let maxWidth;
          if (sign === "text-v1") {
            maxHeight = previewImage.height - this.blocksData[i].config.size;
            maxWidth =
              previewImage.width -
              this.blocksData[i].config.size *
                this.blocksData[i].config.text.length;
          } else {
            maxHeight = previewImage.height - this.blocksData[i].config.height;
            maxWidth = previewImage.width - this.blocksData[i].config.width;
          }
          if (my <= maxHeight && my >= 0 && mx <= maxWidth && mx >= 0) {
            this.blocksData[i].config.x = mx;
            this.blocksData[i].config.y = my;
          }
        }
      }
    },
    close() {
      this.$emit("close");
    },
    createQrcode(val) {
      this.qrcodeStatus = val;
    },
    confirm() {
      if (this.blocksData.length === 0) {
        this.$message.warning("请配置好参数");
        return;
      }
      let params = {};
      for (let i = 0; i < this.blocksData.length; i++) {
        if (this.blocksData[i].sign === "text-v1") {
          Object.assign(params, {
            text: this.blocksData[i].config,
          });
        } else if (this.blocksData[i].sign === "image-v1") {
          Object.assign(params, {
            image: this.blocksData[i].config,
          });
        } else if (this.blocksData[i].sign === "qrcode-v1") {
          Object.assign(params, {
            qrcode: this.blocksData[i].config,
          });
        }
      }
      console.log(params);
      this.$emit("confirm", params);
    },
    dragChange(e) {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let blockSign = e.item.getAttribute("sign");
      // 移除dom
      e.item.parentNode.removeChild(e.item);
      // 默认数据
      let defaultConfig = null;
      if (blockSign === "text-v1") {
        defaultConfig = {
          x: 0,
          y: 0,
          font: "default",
          size: 14,
          color: "#333333",
          type: "var",
          text: "默认文字",
        };
      } else if (blockSign === "image-v1") {
        defaultConfig = {
          x: 0,
          y: 60,
          width: 200,
          height: 100,
          url: "https://img0.baidu.com/it/u=1084374422,3638932364&fm=253&fmt=auto&app=138&f=JPEG?w=140&h=140",
        };
      } else if (blockSign === "qrcode-v1") {
        defaultConfig = {
          x: 0,
          y: 130,
          width: 100,
          height: 100,
          text: "默认内容",
        };
      }
      // 添加block
      this.blocksData.push({
        sign: blockSign,
        config: defaultConfig,
      });

      this.loading = false;
    },
    blockDestroy(index) {
      this.blocksData.splice(index, 1);
      this.curBlockIndex = null;
    },
    saveSetting(index, sign, config) {
      this.blocksData[index] = {
        sign: sign,
        config: config,
      };
    },
  },
};
</script>

<style lang="less" scoped>
.certificate-box-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 2001;
  background-color: rgba(0, 0, 0, 0.5);
}
.certificate-content {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 1200px;
  height: 650px;
  background: #ffffff;
  margin-top: -300px;
  margin-left: -600px;
  box-sizing: border-box;
  .certificate-content-title {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding: 11px 30px;
    font-size: 18px;
    font-weight: 400;
    color: #333333;
    line-height: 18px;
  }
  .certificate-box {
    width: 100%;
    height: 540px;
    float: left;
    display: flex;
    box-sizing: border-box;
    flex-direction: row;
    position: relative;
    .certificate-blocks-box {
      width: 199px;
      height: 100%;
      background-color: white;
      box-sizing: border-box;
      padding: 15px 30px;
      overflow-y: auto;
      .title {
        width: 100%;
        height: auto;
        float: left;
        font-size: 16px;
        font-weight: 600;
        color: #333333;
        line-height: 16px;
        margin-bottom: 15px;
      }
      .tip {
        width: 100%;
        height: auto;
        float: left;
        font-size: 12px;
        font-weight: 400;
        color: #999999;
        line-height: 14px;
        margin-bottom: 30px;
      }
      .blocks {
        width: 100%;
        height: auto;
        float: left;
        display: grid;
        gap: 30px;
        grid-template-columns: repeat(2, minmax(0, 1fr));

        .block-item {
          text-align: center;

          .btn {
            display: inline-block;
            cursor: move;
            width: 60px;
            height: 60px;
            &:hover {
              box-shadow: 0px 4px 8px 0px rgba(102, 102, 102, 0.15);
              border-radius: 8px;
            }

            .name {
              font-size: 12px;
              font-weight: 400;
              color: #666666;
              line-height: 12px;
            }
          }
        }
      }
    }
    .certificate-preview-box {
      width: 700px;
      height: 100%;
      border-left: 1px solid #d8d8d8;
      border-right: 1px solid #d8d8d8;
      box-sizing: border-box;
      .image-box {
        width: 100%;
        height: 100%;
        position: relative;
        overflow-x: auto;
        overflow-y: auto;
        .image-render {
          width: auto;
          height: auto;
          display: block;
        }
        .item {
          position: absolute;
          cursor: pointer;
          &.active {
            box-sizing: border-box;
            border: 2px solid @primary-color;
          }

          .item-options {
            position: absolute;
            top: -2px;
            right: -36px;
            width: auto;
            height: 36px;

            .btn-item {
              color: white;
              background-color: @primary-color;
              width: 36px;
              height: 36px;
              float: left;
              text-align: center;
              line-height: 36px;

              &:hover {
                background-color: rgba(@primary-color, 0.8);
              }

              &:first-child {
                border-top-left-radius: 2px;
                border-bottom-left-radius: 2px;
              }

              &:last-child {
                border-top-right-radius: 2px;
                border-bottom-right-radius: 2px;
              }
            }
          }
        }
      }
    }
    .certificate-config-box {
      width: 299px;
      height: 100%;
      position: relative;
    }
  }
  .certificate-content-footer {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding: 15px 30px;
    box-shadow: 0px -2px 4px 0px rgba(102, 102, 102, 0.05);
    .footer_btn {
      width: 88px;
    }
  }
}
</style>
