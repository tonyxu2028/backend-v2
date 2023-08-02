<template>
  <transition name="fade">
    <div class="upload-dialog-mask">
      <div class="meedu-dialog-box" v-show="!visible">
        <div class="meedu-dialog-header">
          <span>视频列表</span>
        </div>
        <div class="meedu-dialog-body">
          <div class="float-left" v-if="isNoService">
            <div class="d-flex">
              未配置视频存储服务，请前往『系统』-『系统配置』-『视频存储』配置。
            </div>
          </div>
          <div class="float-left">
            <template
              v-if="
                isLocalService &&
                checkPermission('addons.LocalUpload.video.index')
              "
            >
              <div class="float-left j-b-flex mb-15">
                <div class="d-flex">
                  <el-button type="primary" @click="openUploadItem"
                    >上传视频</el-button
                  >
                </div>
                <div class="d-flex">
                  <div class="d-flex">
                    <el-input
                      class="w-150px"
                      v-model="pagination.name"
                      placeholder="视频名称关键词"
                    ></el-input>
                  </div>

                  <div class="ml-10">
                    <el-button @click="paginationReset"> 清空 </el-button>
                    <el-button @click="firstPageLoad" type="primary">
                      筛选
                    </el-button>
                  </div>
                </div>
              </div>
            </template>
            <template v-else-if="isAliService || isTenService">
              <div class="float-left j-b-flex mb-15">
                <div class="d-flex">
                  <el-button type="primary" @click="openUploadItem"
                    >上传视频</el-button
                  >
                </div>
                <div class="d-flex">
                  <div class="d-flex">
                    <el-input
                      class="w-150px"
                      v-model="pagination.keywords"
                      placeholder="视频名称关键词"
                    ></el-input>
                  </div>
                  <div class="ml-10">
                    <el-button @click="paginationReset"> 清空 </el-button>
                    <el-button @click="firstPageLoad" type="primary">
                      筛选
                    </el-button>
                  </div>
                </div>
              </div>
            </template>
            <template v-if="!isNoService">
              <el-table
                :header-cell-style="{ background: '#f1f2f9' }"
                :data="list"
                ref="table"
                highlight-current-row
                @current-change="handleCurrentChange"
                @sort-change="sortChange"
                :default-sort="{ prop: 'id', order: 'descending' }"
                class="float-left mb-15"
                v-loading="loading"
              >
                <template slot="empty">
                  <img
                    class="empty-icon"
                    src="@/assets/images/upload-video/empty.png"
                    alt=""
                  />
                </template>
                <el-table-column label width="55">
                  <template slot-scope="scope">
                    <el-radio :label="scope.row.id" v-model="radio"
                      ><span></span
                    ></el-radio>
                  </template>
                </el-table-column>
                <el-table-column prop="title" label="视频名称">
                </el-table-column>
                <el-table-column
                  property="duration"
                  sortable
                  label="时长"
                  width="90"
                >
                  <template slot-scope="scope">
                    <duration-text
                      v-if="!loading"
                      :duration="scope.row.duration"
                    ></duration-text>
                  </template>
                </el-table-column>
                <el-table-column
                  sortable
                  property="size"
                  label="大小"
                  width="100"
                >
                  <template slot-scope="scope">
                    <span>{{ fileSizeConversion(scope.row.size) }}MB</span>
                  </template>
                </el-table-column>
                <el-table-column
                  property="created_at"
                  sortable
                  label="上传时间"
                  width="120"
                >
                  <template slot-scope="scope">
                    <span>{{ scope.row.created_at | yearFormat }}</span>
                  </template>
                </el-table-column>
                <el-table-column fixed="right" label="操作" width="60">
                  <template slot-scope="scope">
                    <template v-if="scope.row.storage_driver === 'local'">
                      <el-popconfirm
                        title="确认删除吗？"
                        @confirm="destoryLocal(scope.row.storage_file_id)"
                      >
                        <p-link
                          slot="reference"
                          text="删除"
                          p="addons.LocalUpload.video.destroy"
                          type="danger"
                        ></p-link>
                      </el-popconfirm>
                    </template>
                    <template v-else>
                      <el-popconfirm
                        title="确认删除吗？"
                        @confirm="destory(scope.row.id)"
                      >
                        <p-link
                          slot="reference"
                          text="删除"
                          p="media.video.delete.multi"
                          type="danger"
                        ></p-link>
                      </el-popconfirm>
                    </template>
                  </template>
                </el-table-column>
              </el-table>
              <div class="float-left mt-15 text-center" v-if="list.length > 0">
                <el-pagination
                  @size-change="paginationSizeChange"
                  @current-change="paginationPageChange"
                  :current-page="pagination.page"
                  :page-sizes="[7]"
                  :page-size="pagination.size"
                  layout="total, sizes, prev, pager, next, jumper"
                  :total="total"
                >
                </el-pagination>
              </div>
            </template>
          </div>
        </div>
        <div class="meedu-dialog-footer">
          <el-button type="primary" @click="confirm"> 确定 </el-button>
          <el-button @click="close" class="ml-30">取消</el-button>
        </div>
      </div>
      <upload-video-item
        v-if="visible"
        @close="visible = false"
        @change="completeUpload"
      ></upload-video-item>
    </div>
  </transition>
</template>

<script>
import { mapState } from "vuex";
import DurationText from "@/components/duration-text";
import UploadVideoItem from "@/components/upload-video-item";

export default {
  components: {
    DurationText,
    UploadVideoItem,
  },
  props: [],
  data() {
    return {
      pagination: {
        page: 1,
        size: 7,
        keywords: null,
        name: null,
        sort: "id",
        order: "desc",
      },
      list: [],
      total: 0,
      radio: "",
      loading: false,
      upload: {
        // 阿里云obj
        aliyun: null,
        //plupload
        up: null,
        // 上传服务商
        service: null,
        // 是否上传中
        loading: false,
        // 上传进度
        process: 0,
        // 本地视频文件信息
        file: {
          title: null,
          thumb: null,
          size: null,
        },
        // 上传成功视频文件id
        fileId: null,
      },
      // 已选择的视频
      selectedVideo: null,
      visible: false,
    };
  },
  computed: {
    ...mapState(["user", "systemConfig"]),
    tableCurrentRow() {
      if (this.selectedVideo === null) {
        return null;
      }
      let row = null;
      for (let i = 0; i < this.list.length; i++) {
        if (this.list[i].id === this.selectedVideo.id) {
          row = this.list[i];
          break;
        }
      }
      return row;
    },
    isNoService() {
      return this.systemConfig.video.default_service === "";
    },
    isLocalService() {
      return this.systemConfig.video.default_service === "local";
    },
    isTenService() {
      return this.systemConfig.video.default_service === "tencent";
    },
    isAliService() {
      return this.systemConfig.video.default_service === "aliyun";
    },
  },
  watch: {
    visible() {
      this.paginationReset();
    },
    list(data) {
      if (data.length > 0) {
        this.$nextTick(() => {
          this.$refs.table.setCurrentRow(data[0]);
        });
      }
    },
  },
  mounted() {
    this.getData();
  },
  methods: {
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getData();
    },
    openUploadItem() {
      if (this.isNoService) {
        this.$message.warning("请先在系统配置的视频存储中完成参数配置");
        return;
      }
      this.visible = true;
    },
    fileSizeConversion(byte) {
      var size = `${(byte / (1024 * 1024)).toFixed(2)}`;
      const sizeStr = `${size}`;
      const index = sizeStr.indexOf(".");
      const dou = sizeStr.substr(index + 1, 2);
      if (dou == "00") {
        return sizeStr.substring(0, index) + sizeStr.substr(index + 3, 2);
      }
      return size;
    },
    checkPermission(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
    paginationReset() {
      this.pagination.page = 1;
      this.pagination.keywords = null;
      this.pagination.name = null;
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
    handleCurrentChange(row) {
      if (row !== null) {
        this.selectedVideo = row;
        // 清空已上传的
        this.upload.fileId = null;
        this.radio = row.id;
      }
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.getOldList();
    },
    getLocalList() {
      this.$api.System.VideoUpload.List(this.pagination).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;

        if (this.tableCurrentRow !== null) {
          this.$refs["table"].setCurrentRow(this.tableCurrentRow);
        }
      });
    },
    getOldList() {
      this.$api.Media.Video.List(this.pagination).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;

        if (this.tableCurrentRow !== null) {
          this.$refs["table"].setCurrentRow(this.tableCurrentRow);
        }
      });
    },
    confirm() {
      if (this.isNoService) {
        this.$message.warning("请先在系统配置的视频存储中完成参数配置");
        return;
      }
      if (this.selectedVideo === null) {
        this.$message.warning("请选择视频");
        return;
      }
      this.$emit("change", this.selectedVideo);
    },
    close() {
      this.radio = "";
      this.$emit("close");
    },
    completeUpload(val) {
      this.visible = false;
    },
    destory(item) {
      //点击确定按钮的操作
      if (this.loading) {
        return;
      }
      this.loading = true;
      let ids = [];
      ids.push(item);
      this.$api.Media.Video.Destroy({
        ids: ids,
      })
        .then(() => {
          this.loading = false;
          this.$message.success(this.$t("common.success"));
          this.getData();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
    destoryLocal(item) {
      //点击确定按钮的操作
      if (this.loading) {
        return;
      }
      this.loading = true;
      let ids = [];
      ids.push(item);
      this.$api.Resource.LocalVideosDestroyMulti({
        ids: ids,
      })
        .then(() => {
          this.loading = false;
          this.$message.success(this.$t("common.success"));
          this.getData();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
  },
};
</script>

<style lang="less" scoped>
.empty-icon {
  width: 200px;
  height: 200px;
  margin-top: 68px;
  margin-bottom: 98px;
}
.el-button--primary:hover {
  color: #fff;
}
//去掉最下面的那一条线
.el-table::before {
  height: 0px;
}

.upload-dialog-mask {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 2001;
  transform: translateZ(1000px); /*这里是给safari用的*/
  background-color: rgba(0, 0, 0, 0.5);
  .meedu-dialog-box {
    position: absolute;
    top: 50%;
    left: 50%;
    width: 800px;
    height: auto;
    margin-top: -347px;
    margin-left: -400px;
    background-color: white;
    border-radius: 8px;
    animation: scaleBig 0.3s;
    .meedu-dialog-header {
      width: 100%;
      height: auto;
      float: left;
      box-sizing: border-box;
      padding: 30px 30px 20px 30px;
      font-size: 18px;
      font-weight: 500;
      color: #333333;
      line-height: 18px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .meedu-dialog-body {
      width: 100%;
      height: 555px;
      overflow-x: hidden;
      overflow-y: auto;
      float: left;
      box-sizing: border-box;
      padding-left: 30px;
      padding-right: 30px;
    }

    .meedu-dialog-footer {
      width: 100%;
      height: auto;
      float: left;
      box-sizing: border-box;
      padding: 15px 30px;
      border-top: 1px solid #e5e5e5;
    }
  }
}
</style>
<style lang="less">
.el-popconfirm__main {
  margin-block-start: 1em;
  margin-block-end: 1em;
  margin-inline-start: 0px;
  margin-inline-end: 0px;
}
</style>
