<template>
  <div class="config-index-box" v-if="block">
    <div class="config" v-if="block.sign === 'text-v1'">
      <div class="title">
        <div class="text">文本</div>
      </div>
      <div class="config-item" v-if="block.config">
        <div class="config-item-body">
          <div class="float-left">
            <div class="w-100 form-label mb-15">文字内容</div>
            <div class="w-100 float-left import-box">
              <div class="label-item">插入变量：</div>
              <div class="import-item ml-10" @click="addNick" type="primary">
                学员昵称
              </div>
              <div class="import-item ml-10" @click="addMobile" type="primary">
                手机号码
              </div>
              <div class="import-item ml-10" @click="addHour" type="primary">
                学习课时
              </div>
              <div class="import-item ml-10" @click="addTime" type="primary">
                考试时间
              </div>
            </div>
            <div class="float-left d-flex">
              <el-input
                class="w-100"
                type="textarea"
                rows="4"
                resize="none"
                placeholder="此处填写文字内容"
                v-model="block.config.text"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">字体</div>
            <div class="flex-1 ml-15">
              <el-select class="w-100" v-model="block.config.font">
                <el-option label="默认" value="default"> </el-option>
              </el-select>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">大小</div>
            <div class="flex-1 ml-15">
              <el-input
                class="w-100"
                type="number"
                v-model="block.config.size"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">颜色</div>
            <div class="flex-1 ml-15">
              <el-color-picker
                class="w-100"
                v-model="block.config.color"
              ></el-color-picker>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="config" v-else-if="block.sign === 'image-v1'">
      <div class="title">
        <div class="text">图片</div>
      </div>
      <div class="config-item" v-if="block.config">
        <div class="config-item-body">
          <div class="float-left d-flex">
            <el-button @click="showUploadImage = true">上传图片</el-button>
          </div>
          <div class="float-left d-flex w-100 mt-15">
            <img class="pre-icon" :src="block.config.url" />
          </div>
        </div>
      </div>
    </div>
    <div class="config" v-else-if="block.sign === 'qrcode-v1'">
      <div class="title">
        <div class="text">二维码</div>
      </div>
      <div class="config-item" v-if="block.config">
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">内容</div>
            <div class="flex-1 ml-15">
              <el-input class="w-100" v-model="block.config.text"></el-input>
            </div>
          </div>
        </div>
      </div>
    </div>
    <select-image
      :show="showUploadImage"
      :from="1"
      @close="showUploadImage = false"
      @selected="uploadImage"
    ></select-image>
  </div>
</template>
<script>
import SelectImage from "@/components/select-image";
export default {
  props: ["block", "index"],
  components: {
    SelectImage,
  },
  data() {
    return {
      loading: false,
      status: false,
      showUploadImage: false,
    };
  },
  watch: {
    showUploadImage() {
      this.$emit("change", this.showUploadImage);
    },
  },
  mounted() {},
  methods: {
    addNick() {
      this.block.config.text += "${user.nick_name}";
    },
    addMobile() {
      this.block.config.text += "${user.mobile}";
    },
    addHour() {
      this.block.config.text += "${user.hour}";
    },
    addTime() {
      this.block.config.text += "${user.time}";
    },
    uploadImage(src) {
      if (this.block.sign === "image-v1") {
        this.block.config.url = src;
        this.showUploadImage = false;
      }
    },
    update() {
      this.$emit("update", this.index, this.block.sign, this.block.config);
    },
    createQrcode() {
      this.status = !this.status;
      this.$emit("create", this.status);
    },
  },
};
</script>
<style lang="less" scoped>
/deep/.el-textarea__inner {
  border-radius: 0 0 4px 4px;
}
.pre-icon {
  max-width: 100%;
}
.import-box {
  box-sizing: border-box;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  padding: 8px 15px;
  font-size: 12px;
  font-weight: 400;
  border-radius: 4px 4px 0 0;
  border: 1px solid #dcdfe6;
  border-bottom: none;
  .label-item {
    color: #666666;
  }
  .import-item {
    cursor: pointer;
    color: #3ca7fa;
    :hover {
      opacity: 0.8;
    }
  }
}
.config-index-box {
  width: 100%;
  height: 100%;
  float: left;
  box-sizing: border-box;
  padding: 30px;
  position: relative;

  .title {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    border-left: 5px solid #3ca7fa;
    padding-left: 10px;
    font-size: 16px;
    font-weight: 600;
    color: #333333;
    line-height: 16px;
    margin-bottom: 30px;
  }
  .config-item {
    width: 100%;
    height: auto;
    float: left;

    .config-item-body {
      width: 100%;
      height: auto;
      float: left;
      box-sizing: border-box;
      padding-top: 15px;
      padding-bottom: 15px;

      .form-label {
        width: 64px;
        font-size: 14px;
        font-weight: 400;
        color: #666666;
        line-height: 14px;
      }

      .courses-list-box {
        width: 100%;
        height: auto;
        float: left;
        box-sizing: border-box;
        display: grid;
        gap: 10px;
        grid-template-columns: repeat(4, minmax(0, 1fr));

        .course-item {
          position: relative;
          cursor: pointer;

          img {
            border-radius: 4px;
          }

          .default-box {
            border-radius: 4px;
            width: 78px;
            height: 58px;
            border: 1px dashed #dcdfe6;
            font-size: 12px;
            color: #3ca7fa;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .btn-del {
            position: absolute;
            top: -17px;
            right: -17px;
          }
        }
      }
    }
  }
}
</style>
