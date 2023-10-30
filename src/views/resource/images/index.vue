<template>
  <div class="meedu-main-body">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <el-upload
          :headers="uploadHeaders"
          :multiple="true"
          :action="uploadAction"
          :data="uploadData"
          name="file"
          :show-file-list="false"
          :on-success="uploadSuccessEvt"
          accept="image/gif,image/jpeg,image/jpg,image/png"
        >
          <el-button type="primary" class="upbtn">上传图片</el-button>
        </el-upload>
        <el-button
          v-if="selectKey.length > 0"
          class="ml-10"
          @click="cancelAll()"
          >取消操作</el-button
        >
        <el-button
          v-if="selectKey.length === 0"
          class="ml-10"
          @click="selectAll()"
          >批量操作</el-button
        >
        <p-button
          v-if="imageList.length !== 0"
          text="删除"
          p="media.image.delete.multi"
          @click="removeResource()"
          type="danger"
          :disabled="selectKey.length === 0"
        >
        </p-button>
      </div>
    </div>
    <div class="float-left" v-loading="loading">
      <div v-if="imageList.length > 0 || loading" class="images-box">
        <div
          class="imageItem ref-image-item"
          :style="{ 'background-image': 'url(' + item.url + ')' }"
          v-for="item in imageList"
          :key="item.id"
          @click="newPreviewImage(item.url)"
        >
          <i
            @click="onChange(item.id)"
            v-if="selectKey.indexOf(item.id) !== -1"
            class="checked"
          >
            <img src="../../../assets/home/selected.png" />
          </i>
          <i v-else @click="onChange(item.id)" class="checkbox"> </i>
        </div>
      </div>
      <div
        class="float-left text-center"
        v-else-if="!loading && imageList.length === 0"
      >
        <el-empty description="暂无图片"></el-empty>
      </div>
      <div class="float-left mt-30 text-center">
        <el-pagination
          @size-change="paginationSizeChange"
          @current-change="paginationPageChange"
          :current-page="pagination.page"
          :page-sizes="[10, 20, 32, 50, 100]"
          :page-size="pagination.size"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
        >
        </el-pagination>
      </div>
    </div>
    <div v-if="previewImage" class="preview-image borderbox">
      <img
        class="back-detail"
        @click="backDetail()"
        src="@/assets/img/icon-back-n.png"
      />
      <div class="pic-item">
        <div
          class="pic"
          :style="{ 'background-image': 'url(' + thumb + ')' }"
        ></div>
      </div>
    </div>
  </div>
</template>

<script>
import config from "@/js/config";
import { mapState } from "vuex";

export default {
  components: {},
  data() {
    return {
      pageName: "resource-images-list",
      pagination: {
        page: 1,
        size: 32,
      },
      imageList: [],
      selectKey: [],
      visibleArr: [],
      hoverArr: [],
      from: 0,
      total: 0,
      loading: false,
      previewImage: false,
      thumb: null,
    };
  },
  computed: {
    ...mapState(["user", "enabledAddons", "systemConfig"]),
    uploadAction() {
      let url = config.url;
      if (url.substr(-1, 1) === "/") {
        url = url.substr(0, url.length - 1);
      }
      return url + "/backend/api/v1/media/image";
    },
    uploadData() {
      return {
        from: this.from,
      };
    },
    uploadHeaders() {
      return {
        Authorization: "Bearer " + this.$utils.getToken(),
      };
    },
  },
  activated() {
    this.getData();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    uploadSuccessEvt() {
      this.paginationReset();
    },
    paginationReset() {
      this.pagination.page = 1;
      this.selectKey = [];
      this.getData();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getData();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getData();
    },
    firstPageLoad() {
      this.pagination.page = 1;
      this.getData();
    },
    //保存选中结果
    handleSelectionChange(val) {
      var newbox = [];
      for (var i = 0; i < val.length; i++) {
        newbox.push(val[i].id);
      }
      this.selectKey = newbox;
    },
    onChange(id) {
      const arr = [...this.selectKey];
      if (arr.indexOf(id) === -1) {
        arr.push(id);
      } else {
        arr.splice(arr.indexOf(id), 1);
      }
      this.selectKey = arr;
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.pagination);
      this.$api.Resource.ImagesList(params).then((res) => {
        this.loading = false;
        this.imageList = res.data.data.data;
        this.total = res.data.data.total;
        let arr = [];
        for (var i = 0; i < this.imageList.length; i++) {
          arr.push(false);
        }
        this.visibleArr = arr;
        this.hoverArr = arr;
      });
    },
    removeResource() {
      if (this.selectKey.length === 0) {
        this.$message.error("请选择需要操作的数据");
        return;
      }
      this.$confirm("确认操作？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          if (this.loading) {
            return;
          }
          this.loading = true;
          this.$api.Resource.ImagesDestroyMulti({
            ids: this.selectKey,
          })
            .then(() => {
              this.$message.success(this.$t("common.success"));
              this.loading = false;
              this.getData();
            })
            .catch((e) => {
              this.$message.error(e.message);
              this.loading = false;
            });
        })
        .catch(() => {
          //点击删除按钮的操作
        });
    },
    selectAll() {
      let arr = [];
      for (let i = 0; i < this.imageList.length; i++) {
        arr.push(this.imageList[i].id);
      }
      this.selectKey = arr;
    },
    cancelAll() {
      this.selectKey = [];
    },
    showImage(index, value) {
      const arr = [...this.visibleArr];
      arr[index] = value;
      this.visibleArr = arr;
    },
    showHover(index, value) {
      const arr = [...this.hoverArr];
      for (let i = 0; i < arr.length; i++) {
        arr[i] = false;
      }
      arr[index] = value;
      this.hoverArr = arr;
    },
    newPreviewImage(src) {
      this.thumb = src;
      this.previewImage = true;
    },
    backDetail() {
      this.previewImage = false;
    },
  },
};
</script>

<style lang="less" scoped>
.closeButton {
  position: absolute;
  right: -8px;
  top: -8px;
}

.checkbox {
  width: 20px;
  height: 20px;
  background: rgba(#ffffff, 0.6);
  border-radius: 3px;
  border: 2px solid #d9d9d9;
  position: absolute;
  left: 10px;
  top: 10px;
  z-index: 100;
  cursor: pointer;
}

.checked {
  width: 20px;
  height: 20px;
  background: #3ca7fa;
  border-radius: 3px;
  border: 2px solid #3ca7fa;
  position: absolute;
  left: 10px;
  top: 10px;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  cursor: pointer;
  img {
    width: 20px;
    height: 20px;
  }
}

.images-box {
  display: grid;
  gap: 24px;
  grid-template-columns: repeat(8, minmax(0, 1fr));

  .imageItem {
    width: 100%;
    height: auto;
    aspect-ratio: 1/1;
    background-repeat: no-repeat;
    background-size: contain;
    background-position: center center;
    background-color: #f6f6f6;
    border-radius: 6px;
    overflow: hidden;
    position: relative;
    cursor: pointer;
    &:hover {
      opacity: 0.8;
    }
  }
}
.preview-image {
  width: 100%;
  height: 100%;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 400;
  padding: 15px;
  background-color: #000000;
  display: flex;
  align-items: center;
  .back-detail {
    position: absolute;
    top: 15px;
    left: 15px;
    width: 19px;
    height: 19px;
    cursor: pointer;
  }
  .pic-item {
    width: 100%;
    height: 100%;
    .pic {
      width: 100%;
      height: 100%;
      background-repeat: no-repeat;
      background-size: contain;
      background-position: center center;
    }
  }
}
</style>
