<template>
  <div class="bg" v-loading="loading">
    <div class="certificate-content">
      <div class="top-box">
        <div class="btn-back" @click="$router.back()">
          <i class="el-icon-back"></i>
          返回
        </div>
        <div class="line"></div>
        <div class="name">编辑证书</div>
      </div>
      <div
        :class="{
          noleft: leftArrrow,
        }"
        class="left-arrrow"
        @click="leftArrrow = !leftArrrow"
      >
        <img
          v-if="leftArrrow"
          src="@/assets/images/certificate/icon-unfold.png"
          width="44"
          height="44"
        />
        <img
          v-else
          src="@/assets/images/certificate/icon-fold.png"
          width="44"
          height="44"
        />
      </div>
      <div class="certificate-blocks-box" v-show="!leftArrrow">
        <div class="title">基本信息</div>
        <div class="line"></div>
        <div class="float-left mt-30">
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
                  :height="280"
                  v-model="course.template_image"
                  :name="uploadName"
                ></upload-image>
              </el-form-item>
              <el-form-item
                class="is-required"
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

      <div
        class="choose_size_box"
        :class="{ rightArrow: curBlockIndex !== null }"
      >
        <div class="tab_narrow" @click="changeSize(-1)">
          <img
            src="@/assets/images/certificate/low.png"
            width="12"
            height="12"
          />
        </div>
        <div class="choose_size ml-15 mr-15">
          <el-dropdown trigger="click">
            <span class="el-dropdown-link"> {{ size * 100 }}% </span>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item @click.native="changeSize(2)"
                >200%</el-dropdown-item
              >
              <el-dropdown-item @click.native="changeSize(1.5)"
                >150%</el-dropdown-item
              >
              <el-dropdown-item @click.native="changeSize(1)"
                >100%</el-dropdown-item
              >
              <el-dropdown-item @click.native="changeSize(0.5)"
                >50%</el-dropdown-item
              >
              <el-dropdown-item @click.native="changeSize(0.25)"
                >25%</el-dropdown-item
              >
            </el-dropdown-menu>
          </el-dropdown>
        </div>
        <div class="tab_enlarge" @click="changeSize(0)">
          <img
            src="@/assets/images/certificate/high.png"
            width="12"
            height="12"
          />
        </div>
      </div>
      <vue-drag-resize
        class="certificate-preview-box"
        w="auto"
        h="auto"
        :x="dragX"
        :y="dragY"
        ref="dragBox"
        @dragging="onDrag"
        :isResizable="false"
      >
        <draggable
          v-if="originalWidth && originalHeight"
          ref="preview-box"
          class="preview-box"
          :style="{
            width: originalWidth + 'px',
            height: originalHeight + 'px',
          }"
          draggable=".block-item"
          group="blocks"
          @add="dragChange"
        >
          <div
            class="image-box"
            :style="{
              'background-image': 'url(' + image + ')',
              'background-position': 'center center',
              'background-size': 'cover',
              'background-repeat': 'no-repeat',
            }"
          >
            <template v-for="(item, index) in blocksData">
              <render-image-v1
                :key="item.id"
                v-if="item.sign === 'image-v1' && fresh"
                :current="index"
                :config="item.config"
                :status="curBlockIndex"
                :size="size"
                @dragend="changePosition"
                @change="changeIndex"
                @del="delBlockMethod"
              ></render-image-v1>
              <render-qrcode-v1
                :key="item.id"
                v-else-if="item.sign === 'qrcode-v1' && fresh"
                :current="index"
                :config="item.config"
                :status="qrcodeStatus"
                :curindex="curBlockIndex"
                :size="size"
                @dragend="changePosition"
                @change="changeIndex"
                @del="delBlockMethod"
              ></render-qrcode-v1>
              <render-text-v1
                :key="item.id"
                v-else-if="item.sign === 'text-v1' && fresh"
                :current="index"
                :config="item.config"
                :status="curBlockIndex"
                :maxw="originalWidth"
                :size="size"
                @dragend="changePosition"
                @change="changeIndex"
                @del="delBlockMethod"
              ></render-text-v1>
            </template>
          </div>
        </draggable>
      </vue-drag-resize>
      <div
        class="certificate-config-box"
        :class="{
          active: rightIndex,
        }"
        v-if="curBlockIndex !== null"
      >
        <div class="float-left mb-15">
          <el-button class="ml-15 mt-15" @click="curBlockIndex = null">
            <i class="el-icon-close"></i><span class="ml-5">关闭配置</span>
          </el-button>
        </div>
        <config-setting
          :block="blocksData[curBlockIndex]"
          :index="curBlockIndex"
          @create="createQrcode"
          @change="getIndex"
        ></config-setting>
      </div>
      <div class="bottom-menus">
        <div class="bottom-menus-box" style="left: 0; z-index: 1000">
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
  </div>
</template>
<script>
import demoImg from "@/assets/home/demo.png";
import UploadImage from "@/components/upload-image";
import VueDragResize from "vue-drag-resize";
import draggable from "vuedraggable";
import ConfigSetting from "./components/certificate-config.vue";
import RenderTextV1 from "./render/text-v1.vue";
import RenderImageV1 from "./render/image-v1.vue";
import RenderQrcodeV1 from "./render/qrcode-v1.vue";
export default {
  components: {
    VueDragResize,
    draggable,
    ConfigSetting,
    RenderTextV1,
    RenderImageV1,
    RenderQrcodeV1,
    UploadImage,
  },
  data() {
    return {
      id: this.$route.query.id,
      loading: false,
      params: "",
      uploadName: "上传背景",
      blocksData: [],
      curBlockIndex: null,
      qrcodeStatus: null,
      image: null,
      originalHeight: null,
      originalWidth: null,
      imgHeight: null,
      imgWidth: null,
      course: {
        name: null,
        template_image: null,
        params: null,
      },
      fresh: true,
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
      leftArrrow: false,
      size: 0.5,
      dragX: 0,
      dragY: 106,
      rightIndex: null,
    };
  },
  watch: {
    "course.template_image"(val) {
      this.image = val;
      this.getImgInfo();
      if (val) {
        this.uploadName = "重新上传";
      } else {
        this.uploadName = "上传背景";
      }
    },
    size() {
      this.fresh = false;
      this.$nextTick(() => {
        this.fresh = true;
      });
    },
  },
  mounted() {
    this.getDetail();
    this.keyDown();
    window.addEventListener("mousewheel", this.handleScroll, {
      passive: false,
    });
  },
  beforeDestroy() {
    window.removeEventListener("mousewheel", this.handleScroll, {
      passive: false,
    });
  },
  methods: {
    keyDown() {
      document.onkeydown = (e) => {
        let e1 =
          e || event || window.event || arguments.callee.caller.arguments[0];
        if (e1 && e1.keyCode == 37) {
          if (!this.image) {
            return;
          }
          this.dragX -= 50;
        } else if (e1 && e1.keyCode == 39) {
          if (!this.image) {
            return;
          }
          this.dragX += 50;
        } else if (e1 && e1.keyCode == 38) {
          if (!this.image) {
            return;
          }
          this.dragY -= 50;
        } else if (e1 && e1.keyCode == 40) {
          if (!this.image) {
            return;
          }
          this.dragY += 50;
        }
      };
    },
    handleScroll(e) {
      if (e.deltaY > 0) {
        if (!this.image) {
          return;
        }
        this.dragY -= 40;
      } else {
        if (!this.image) {
          return;
        }
        this.dragY += 40;
      }
      // 判断是不是按下ctrl键
      if (e.ctrlKey) {
        // 取消浏览器默认的放大缩小网页行为
        e.preventDefault();
        // 判断是向上滚动还是向下滚动
        if (e.deltaY > 0) {
          // 放大重写，业务代码
          this.changeSize(0);
        } else {
          // 缩小重写，业务代码
          this.changeSize(-1);
        }
      }
    },
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
    getDetail() {
      this.$api.Certificate.Detail(this.id).then((res) => {
        let data = res.data;
        this.course = data;
        let params = JSON.parse(data.params);
        for (let i = 0; i < params.length; i++) {
          if (params[i].image) {
            let item = {
              sign: "image-v1",
              config: params[i].image,
            };
            this.blocksData.push(item);
          } else if (params[i].text) {
            let item = {
              sign: "text-v1",
              config: params[i].text,
            };
            this.blocksData.push(item);
          } else if (params[i].qrcode) {
            let item = {
              sign: "qrcode-v1",
              config: params[i].qrcode,
            };
            this.blocksData.push(item);
          }
        }
      });
    },
    changeIndex(index) {
      this.curBlockIndex = index;
    },
    delBlockMethod(index) {
      this.blockDestroy(index);
    },
    getIndex(val) {
      this.rightIndex = val;
    },
    onDrag(e) {
      this.dragX = e.left;
      this.dragY = e.top;
    },
    changeSize(val) {
      if (!this.image) {
        this.$message.error("请上传证书背景后在改变缩放比例");
        return;
      }
      if (val === -1) {
        if (this.size === 0.25) {
          return;
        }
        this.size -= 0.25;
        this.originalHeight = this.size * this.imgHeight;
        this.originalWidth = this.size * this.imgWidth;
        this.dragX = 0.5 * (window.screen.width - this.originalWidth);
        this.dragY = 106;
      } else if (val === 0) {
        if (this.size === 2) {
          return;
        }
        this.size += 0.25;
        this.originalHeight = this.size * this.imgHeight;
        this.originalWidth = this.size * this.imgWidth;
        this.dragX = 0.5 * (window.screen.width - this.originalWidth);
        this.dragY = 106;
      } else {
        this.size = val;
        this.originalHeight = this.size * this.imgHeight;
        this.originalWidth = this.size * this.imgWidth;
        this.dragX = 0.5 * (window.screen.width - this.originalWidth);
        this.dragY = 106;
      }
    },
    getImgInfo() {
      let self = this;
      let img = new Image();
      img.src = self.image;
      img.onload = function () {
        self.imgHeight = img.height;
        self.imgWidth = img.width;
        self.originalHeight = self.size * img.height;
        self.originalWidth = self.size * img.width;
        self.dragX = 0.5 * (window.screen.width - self.originalWidth);
        self.dragY = 106;
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
      for (let i = 0; i < this.blocksData.length; i++) {
        if (this.blocksData[i].sign === sign && i === index) {
          let mx = moveX;
          let my = moveY;
          let maxHeight;
          let maxWidth;
          if (my >= 0 && mx >= 0) {
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
      this.course.params = JSON.stringify(params);
      this.loading = true;
      this.$api.Certificate.Update(this.id, this.course)
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
          width: 100,
          height: 100,
          url: demoImg,
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
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
  height: 100%;
  background-color: #f1f2f9;
  z-index: 1000;
}
.top-box {
  position: fixed;
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
  z-index: 10;

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
.left-arrrow {
  position: absolute;
  top: 75px;
  left: 384px;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  z-index: 10;
  &.noleft {
    left: -15px;
  }
}

.certificate-blocks-box {
  height: calc(100vh - 138px);
  position: absolute;
  top: 57px;
  /* left: 70px; */
  left: 0;
  /* border-radius: 4px; */
  /* will-change: contents; */
  transition: left ease 0.5s;
  width: 400px;
  background-color: white;
  box-sizing: border-box;
  padding: 30px;
  z-index: 11111;
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
.certificate-content {
  /* will-change: auto; */
  width: 100%;
  height: 100%;
  position: absolute;
  overflow: hidden;
  box-sizing: border-box;
  top: 0;
  left: 0;
  background: #f0f2f5;
  z-index: 1002;
}
.choose_size_box {
  position: absolute;
  top: 86px;
  right: 30px;
  width: 103px;
  height: 40px;
  background: #ffffff;
  box-shadow: 0px 4px 8px 0px rgba(102, 102, 102, 0.15);
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
  cursor: pointer;
  &.rightArrow {
    right: 430px;
  }
  .tab_narrow {
    width: 20px;
    display: flex;
    align-items: center;
    justify-content: right;
  }
  .choose_size {
    display: inline-block;
    font-size: 14px;
    font-weight: 400;
    color: #333333;
    line-height: 20px;
  }
  .tab_enlarge {
    width: 20px;
    display: flex;
    align-items: center;
    justify-content: left;
  }
}
.certificate-preview-box {
  background: #f1f2f9;
  box-sizing: border-box;
  position: absolute;
  top: 0;
  left: 0;
  transition: none;
  background: transparent;
  z-index: 0;
  box-shadow: none;
  .preview-box {
    overflow: hidden;
  }
  .image-box {
    width: 100%;
    height: 100%;
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
  height: calc(100vh - 57px);
  position: absolute;
  top: 57px;
  right: 0;
  bottom: 0;
  width: 400px;
  box-sizing: border-box;
  background-color: white;
  border-left: 1px solid #f2f2f2;
  z-index: 100;
  &.active {
    z-index: 11111;
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
</style>
