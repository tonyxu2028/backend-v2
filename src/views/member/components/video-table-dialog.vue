<template>
  <div>
    <transition name="fade">
      <div class="meedu-dialog-mask">
        <div class="meedu-table-dialog-box">
          <div class="meedu-table-dialog-header">
            <span>{{ text }}</span>
            <img
              class="icon-close"
              @click="close()"
              src="@/assets/img/close.png"
            />
          </div>
          <div class="meedu-table-dialog-body">
            <el-table
              :header-cell-style="{ background: '#f1f2f9' }"
              :data="list"
              class="float-left"
            >
              <el-table-column label="课时名称" min-width="20%">
                <template slot-scope="scope">
                  <template>
                    <span>{{ scope.row.title }}</span>
                  </template>
                </template>
              </el-table-column>
              <el-table-column
                property="duration"
                label="课时时长"
                min-width="13%"
                ><template slot-scope="scope">
                  <duration-text
                    v-if="!loading"
                    :duration="scope.row.duration"
                  ></duration-text>
                </template>
              </el-table-column>
              <el-table-column
                property="duration"
                label="已学时长"
                min-width="13%"
                ><template slot-scope="scope">
                  <template
                    v-if="
                      typeof scope.row.watch_record['watch_seconds'] !==
                      'undefined'
                    "
                  >
                    <duration-text
                      :duration="scope.row.watch_record.watch_seconds"
                    ></duration-text>
                  </template>
                  <span v-else>-</span>
                </template>
              </el-table-column>
              <el-table-column label="是否学完" min-width="10%">
                <template slot-scope="scope">
                  <span
                    class="c-green"
                    v-if="
                      typeof scope.row.watch_record['watched_at'] !==
                        'undefined' && scope.row.watch_record.watched_at
                    "
                    >已学完</span
                  >
                  <span v-else>未学完</span>
                </template>
              </el-table-column>
              <el-table-column label="开始学习时间" min-width="16%">
                <template slot-scope="scope">
                  <span
                    v-if="
                      typeof scope.row.watch_record['created_at'] !==
                        'undefined' && scope.row.watch_record.created_at
                    "
                    >{{ scope.row.watch_record.created_at | dateFormat }}</span
                  >
                  <span v-else>-</span>
                </template>
              </el-table-column>
              <el-table-column label="最近一次学习" min-width="16%">
                <template slot-scope="scope">
                  <span
                    v-if="
                      typeof scope.row.watch_record['updated_at'] !==
                        'undefined' && scope.row.watch_record.updated_at
                    "
                    >{{ scope.row.watch_record.updated_at | dateFormat }}</span
                  >
                  <span v-else>-</span>
                </template>
              </el-table-column>
              <template v-if="enabledAddons['Snapshot']">
                <el-table-column label="已拍照片" width="120">
                  <template slot-scope="scope">
                    <el-link
                      type="primary"
                      v-if="
                        images[scope.row.id] &&
                        images[scope.row.id].images.length > 0
                      "
                      @click="showDialog(scope.row.id)"
                    >
                      {{ images[scope.row.id].images.length }}
                    </el-link>
                    <span v-else>-</span>
                  </template>
                </el-table-column>
              </template>
            </el-table>
          </div>
        </div>
      </div>
    </transition>
    <snapshot-dialog
      v-if="visiable"
      :uid="userId"
      :vid="vid"
      @close="hideDialog()"
    ></snapshot-dialog>
  </div>
</template>
<script>
import { mapState } from "vuex";
import DurationText from "@/components/duration-text";
import SnapshotDialog from "@/components/snapshot-dialog";
export default {
  components: {
    DurationText,
    SnapshotDialog,
  },
  props: ["id", "text", "userId"],
  computed: {
    ...mapState(["enabledAddons"]),
  },
  data() {
    return {
      loading: false,
      list: [],
      visiable: false,
      vid: null,
      images: {},
    };
  },
  mounted() {
    if (this.id && this.userId) {
      this.getData();
    }
  },
  methods: {
    showDialog(vid) {
      this.vid = vid;
      this.visiable = true;
    },
    hideDialog() {
      this.vid = null;
      this.visiable = false;
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {
        course_id: this.id,
        user_id: this.userId,
      };
      this.$api.Member.UserVideoWatchRecords(params).then((res) => {
        this.loading = false;
        let videos = res.data.videos;
        let list = [];
        let arr = [];
        for (let i in videos) {
          list.push(videos[i]);
          arr.push(videos[i].id);
        }
        this.list = list;
        this.ids = arr;
        if (this.enabledAddons["Snapshot"]) {
          this.getImages(arr);
        }
      });
    },
    getImages(ids) {
      let params = {
        type: "vod",
        user_id: this.userId,
        other_ids: ids,
      };
      this.$api.Snapshot.Images.List(params)
        .then((res) => {
          this.images = res.data;
        })
        .catch((e) => {
          this.$message.error(e.message);
        });
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>
