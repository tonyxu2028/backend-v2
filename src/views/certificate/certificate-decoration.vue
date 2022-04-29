<template>
  <div class="bg" v-loading="loading">
    <div class="top-box">
      <div class="btn-back" @click="$router.back()">
        <i class="el-icon-back"></i>
        返回
      </div>
      <div class="line"></div>
      <div class="name">新建证书</div>
    </div>
    <div class="certificate-blocks-box">
      <div class="title">基本信息</div>
      <div class="line"></div>
      <div class="float-left">
        <el-form
          ref="form"
          :model="course"
          :rules="rules"
          class="float-left"
          label-width="90px"
        >
          <div class="float-left">
            <el-form-item label="证书名称" prop="name">
              <div class="d-flex">
                <div>
                  <el-input
                    maxlength="64"
                    v-model="course.name"
                    class="w-250px"
                    placeholder="填写证书名称"
                  ></el-input>
                </div>
              </div>
            </el-form-item>

            <el-form-item prop="template_image" label="证书背景">
              <upload-image
                v-model="course.template_image"
                width="90"
                height="120"
                name="上传背景"
              ></upload-image>
            </el-form-item>
            <el-form-item
              prop="params"
              label="证书元素"
              v-if="course.template_image"
            >
              <helper-text text="拖动元素到证书背景上编辑参数"></helper-text>
            </el-form-item>
          </div>
        </el-form>
      </div>
      <draggable
        v-if="course.template_image"
        class="blocks"
        :sort="false"
        :group="{ name: 'blocks', pull: 'clone', put: false }"
      >
        <div class="block-item" sign="text-v1">
          <div class="btn">
            <div class="icon">
              <img
                src="@/assets/images/certificate/icon-txt.png"
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
                src="@/assets/images/certificate/icon-img.png"
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
                src="@/assets/images/certificate/icon-qrcode.png"
                width="44"
                height="44"
              />
            </div>
            <div class="name">二维码</div>
          </div>
        </div>
      </draggable>
    </div>
    <div class="certificate-content">
      <draggable
        ref="preview-box"
        class="certificate-preview-box"
        draggable=".block-item"
        group="blocks"
        @add="dragChange"
      >
        <div
          class="image-box"
          :style="{
            width: originalWidth + 'px',
            height: originalHeight + 'px',
          }"
        >
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
    <div class="bottom-menus">
      <div class="bottom-menus-box" style="left: 400px">
        <div>
          <el-button @click="formValidate" :loading="loading" type="primary"
            >确定</el-button
          >
        </div>
        <div class="ml-24">
          <el-button @click="$router.back()">取消</el-button>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import UploadImage from "@/components/upload-image";
import draggable from "vuedraggable";
import ConfigSetting from "./components/certificate-config.vue";
import RenderTextV1 from "./render/text-v1.vue";
import RenderImageV1 from "./render/image-v1.vue";
import RenderQrcodeV1 from "./render/qrcode-v1.vue";
export default {
  components: {
    draggable,
    ConfigSetting,
    RenderTextV1,
    RenderImageV1,
    RenderQrcodeV1,
    UploadImage,
  },
  data() {
    return {
      loading: false,
      params: "",
      blocksData: [],
      curBlockIndex: null,
      qrcodeStatus: null,
      image: null,
      originalHeight: null,
      originalWidth: null,
      course: {
        name: null,
        template_image: null,
        params: null,
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
      },
      categories: [],
    };
  },
  watch: {
    "course.template_image"(val) {
      this.image = val;
      this.getImgInfo();
    },
  },
  mounted() {},
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
    getImgInfo() {
      let self = this;
      let img = new Image();
      img.src = self.image;
      img.onload = function () {
        self.originalHeight = 0.5 * img.height;
        self.originalWidth = 0.5 * img.width;
        console.log("图片原始高度", img.height);
        console.log("图片原始宽度", img.width);
      };
    },
    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.confirm();
        }
      });
    },
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
      if (this.loading) {
        return;
      }
      if (this.blocksData.length === 0) {
        this.$message.warning("请配置好证书元素");
        return;
      }
      let params = [];
      for (let i = 0; i < this.blocksData.length; i++) {
        if (this.blocksData[i].sign === "text-v1") {
          params.push({
            text: this.blocksData[i].config,
          });
        } else if (this.blocksData[i].sign === "image-v1") {
          params.push({
            image: this.blocksData[i].config,
          });
        } else if (this.blocksData[i].sign === "qrcode-v1") {
          params.push({
            qrcode: this.blocksData[i].config,
          });
        }
      }
      console.log(params);
      this.course.params = JSON.stringify(params);

      // if (!this.isJSON(this.course.params)) {
      //   this.$message.error("请输入JSON字符串");
      //   return;
      // }
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
.bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #f1f2f9;
}
.top-box {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  height: 56px;
  float: left;
  box-sizing: border-box;
  padding-left: 30px;
  padding-right: 30px;
  background-color: white;
  line-height: 56px;
  border-bottom: 1px solid #f2f2f2;

  .btn-back {
    font-size: 14px;
    font-weight: 400;
    color: #333333;
    cursor: pointer;

    &:hover {
      color: @primary-color;
    }
  }

  .line {
    width: 1px;
    height: 14px;
    background-color: #d8d8d8;
    margin-right: 15px;
    margin-left: 15px;
  }

  .name {
    font-size: 14px;
    font-weight: 600;
    color: #333333;
  }
}
.certificate-content {
  position: absolute;
  top: 56px;
  left: 400px;
  bottom: 0;
  width: calc(100% - 400px);
  height: 100%;
  display: flex;
  flex-direction: row;
}

.certificate-blocks-box {
  position: absolute;
  top: 56px;
  left: 0;
  bottom: 0;
  width: 400px;
  background-color: white;
  box-sizing: border-box;
  padding: 30px;
  overflow-y: auto;
  .title {
    width: 100%;
    height: 16px;
    border-left: 4px solid #3ca7fa;
    font-size: 14px;
    line-height: 16px;
    font-weight: 600;
    color: #333333;
    box-sizing: border-box;
    padding-left: 10px;
    margin-bottom: 30px;
  }
  .line {
    width: 100%;
    height: 1px;
    background: #f1f2f9;
  }
  .blocks {
    width: 100%;
    height: auto;
    float: left;
    display: grid;
    box-sizing: border-box;
    padding: 0 20px;
    gap: 30px;
    grid-template-columns: repeat(3, minmax(0, 1fr));

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
  width: calc(100% - 400px);
  height: 100%;
  background-color: #f6f6f6;
  box-sizing: border-box;
  overflow-x: auto;
  display: flex;
  justify-content: center;
  .image-box {
    margin: 0 auto;
    position: relative;
    .image-render {
      width: 100%;
      height: 100%;
      display: block;
      .image {
        width: 100%;
        height: 100%;
      }
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
  width: 400px;
  height: 100%;
  position: relative;
  background: white;
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
</style>
