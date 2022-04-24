<template>
  <div class="config-index-box" v-if="block">
    <div class="config" v-if="block.sign === 'text-v1'">
      <div class="title">
        <div class="text">文本</div>
      </div>
      <div class="config-item" v-if="block.config">
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">横坐标x</div>
            <div class="flex-1 ml-15">
              <el-input
                type="number"
                class="w-100"
                v-model="block.config.x"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">纵坐标y</div>
            <div class="flex-1 ml-15">
              <el-input
                type="number"
                class="w-100"
                v-model="block.config.y"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">字体</div>
            <div class="flex-1 ml-15">
              <el-select class="w-100" v-model="block.config.font">
                <el-option label="default" value="default"> </el-option>
              </el-select>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">字体大小</div>
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
            <div class="form-label">颜色色号</div>
            <div class="flex-1 ml-15">
              <el-color-picker
                class="w-100"
                v-model="block.config.color"
              ></el-color-picker>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">类型</div>
            <div class="flex-1 ml-15">
              <el-select class="w-100" v-model="block.config.type">
                <el-option label="pure" value="pure"> </el-option>
                <el-option label="var" value="var"> </el-option>
              </el-select>
            </div>
          </div>
        </div>
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
    <div class="config" v-else-if="block.sign === 'image-v1'">
      <div class="title">
        <div class="text">图片</div>
      </div>
      <div class="config-item" v-if="block.config">
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">横坐标x</div>
            <div class="flex-1 ml-15">
              <el-input
                type="number"
                class="w-100"
                v-model="block.config.x"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">纵坐标y</div>
            <div class="flex-1 ml-15">
              <el-input
                type="number"
                class="w-100"
                v-model="block.config.y"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">宽度</div>
            <div class="flex-1 ml-15">
              <el-input
                class="w-100"
                type="number"
                v-model="block.config.width"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">高度</div>
            <div class="flex-1 ml-15">
              <el-input
                class="w-100"
                type="number"
                v-model="block.config.height"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">图片地址</div>
            <div class="flex-1 ml-15">
              <el-input class="w-100" v-model="block.config.url"></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left j-flex">
            <el-button type="primary" @click="showUploadImage = true"
              >上传图片</el-button
            >
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
            <div class="form-label">横坐标x</div>
            <div class="flex-1 ml-15">
              <el-input
                type="number"
                class="w-100"
                v-model="block.config.x"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">纵坐标y</div>
            <div class="flex-1 ml-15">
              <el-input
                type="number"
                class="w-100"
                v-model="block.config.y"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">宽度</div>
            <div class="flex-1 ml-15">
              <el-input
                class="w-100"
                type="number"
                v-model="block.config.width"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">高度</div>
            <div class="flex-1 ml-15">
              <el-input
                class="w-100"
                type="number"
                v-model="block.config.height"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">二维码内容</div>
            <div class="flex-1 ml-15">
              <el-input class="w-100" v-model="block.config.text"></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left j-flex">
            <el-button type="primary" @click="createQrcode"
              >生成二维码</el-button
            >
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
  mounted() {},
  methods: {
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
.config-index-box {
  width: 100%;
  height: 460px;
  float: left;
  overflow-y: auto;
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
