<template>
  <transition name="fade">
    <div class="meedu-dialog-mask">
      <div class="meedu-table-dialog-box">
        <div class="meedu-table-dialog-header">
          <span>学习照片</span>
          <img
            class="icon-close"
            @click="close()"
            src="@/assets/img/close.png"
          />
        </div>

        <div class="meedu-table-dialog-body" v-loading="loading">
          <div class="float-left mb-30">
            <p-button
              text="批量删除"
              p="addons.Snapshot.images.delete"
              @click="destorymulti"
              type="danger"
            >
            </p-button>
          </div>
          <el-table
            :data="images"
            @selection-change="handleSelectionChange"
            class="float-left"
          >
            <el-table-column type="selection" width="55"></el-table-column>
            <el-table-column prop="id" label="ID" width="100">
            </el-table-column>
            <el-table-column label="拍照时间">
              <template slot-scope="scope">{{
                scope.row.created_at | dateFormat
              }}</template>
            </el-table-column>
            <el-table-column fixed="right" label="操作" width="250">
              <template slot-scope="scope">
                <el-image
                  style="width: 100px; height: 100px"
                  :src="scope.row.thumb"
                  :preview-src-list="srcList"
                >
                </el-image>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  props: ["vid", "uid"],
  data() {
    return {
      loading: false,
      spids: {
        ids: [],
      },
      srcList: [],
      images: [],
      rid: null,
    };
  },
  mounted() {
    if (this.vid) {
      this.getData();
    }
  },
  methods: {
    handleSelectionChange(val) {
      var newbox = [];
      for (var i = 0; i < val.length; i++) {
        newbox.push(val[i].id);
      }
      this.spids.ids = newbox;
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let arr = [];
      arr.push(this.vid);
      let params = {
        type: "vod",
        user_id: this.uid,
        other_ids: arr,
      };
      this.$api.Snapshot.Images.List(params).then((res) => {
        this.loading = false;
        this.rid = res.data[this.vid].id;
        this.images = res.data[this.vid].images;
        this.showPreview();
      });
    },
    showPreview() {
      let images = [];
      this.images.forEach((item) => {
        images.push(item.thumb);
      });
      this.srcList = images;
    },
    destorymulti() {
      if (this.spids.ids == "") {
        this.$message.warning("请选择需要操作的数据");
        return;
      }
      this.$confirm("确认操作？", "警告", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          //点击确定按钮的操作
          if (this.loading) {
            return;
          }
          this.loading = true;
          this.$api.Snapshot.Images.Destorymulti({
            ids: this.spids.ids,
            rid: this.rid,
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
        })
        .catch(() => {
          //点击删除按钮的操作
        });
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>
