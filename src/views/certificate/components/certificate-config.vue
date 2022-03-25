<template>
  <div class="config-index-box">
    <div class="config" v-if="block.sign === 'text-v1'">
      <div class="title">
        <div class="text">文本</div>
      </div>
      <div class="config-item" v-if="config">
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">横坐标x</div>
            <div class="flex-1 ml-15">
              <el-input
                type="number"
                class="w-100"
                v-model="config.x"
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
                v-model="config.y"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">字体</div>
            <div class="flex-1 ml-15">
              <el-input class="w-100" v-model="config.font"></el-input>
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
                v-model="config.size"
              ></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">颜色色号</div>
            <div class="flex-1 ml-15">
              <el-input class="w-100" v-model="config.color"></el-input>
            </div>
          </div>
        </div>
        <div class="config-item-body">
          <div class="float-left d-flex">
            <div class="form-label">类型</div>
            <div class="flex-1 ml-15">
              <el-select class="w-100" v-model="config.type">
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
              <el-input class="w-100" v-model="config.text"></el-input>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="config" v-else-if="block.sign === 'image-v1'">222</div>
    <div class="config" v-else-if="block.sign === 'qrcode-v1'">333</div>
  </div>
</template>
<script>
export default {
  props: ["block", "index"],
  data() {
    return {
      config: null,
      loading: false,
    };
  },
  mounted() {
    this.config = this.block.config;
  },
  methods: {
    update() {
      this.$emit("update", this.index, this.block.sign, this.block.config);
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
