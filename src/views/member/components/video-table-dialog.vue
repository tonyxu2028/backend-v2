<template>
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
            @sort-change="sortChange"
            :default-sort="{ prop: 'published_at', order: 'ascending' }"
          >
            <el-table-column label="课时名称" min-width="32%">
              <template slot-scope="scope">
                <template>
                  <template v-if="scope.row.chapter">
                    <span>{{ scope.row.chapter.title }}</span>
                    <span class="mx-5">/</span>
                  </template>
                  <span>{{ scope.row.title }}</span>
                </template>
              </template>
            </el-table-column>
            <el-table-column
              property="duration"
              label="课时时长"
              sortable
              min-width="13%"
              ><template slot-scope="scope">
                <duration-text
                  v-if="scope.row.duration"
                  :duration="scope.row.duration"
                ></duration-text>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column
              property="duration"
              label="已学时长"
              sortable
              min-width="13%"
              ><template slot-scope="scope">
                <duration-text
                  v-if="scope.row.duration"
                  :duration="scope.row.duration"
                ></duration-text>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column label="是否学完" min-width="10%">
              <template slot-scope="scope">
                <span class="c-green" v-if="scope.row.is_show === 1"
                  >已学完</span
                >
                <span v-else>未学完</span>
              </template>
            </el-table-column>
            <el-table-column sortable label="开始学习时间" min-width="16%">
              <template slot-scope="scope">
                <span v-if="scope.row.published_at">{{
                  scope.row.published_at | dateFormat
                }}</span>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column sortable label="最近一次学习" min-width="16%">
              <template slot-scope="scope">
                <span v-if="scope.row.published_at">{{
                  scope.row.published_at | dateFormat
                }}</span>
                <span v-else>-</span>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>
  </transition>
</template>
<script>
import DurationText from "@/components/duration-text";
export default {
  components: {
    DurationText,
  },
  props: ["id", "text"],
  data() {
    return {
      pagination: {
        page: 1,
        size: 10000,
        sort: "published_at",
        order: "asc",
      },
      loading: false,
      list: [],
      total: 0,
    };
  },
  mounted() {
    if (this.id) {
      this.getData();
    }
  },
  methods: {
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getData();
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.pagination, {
        cid: this.id,
      });
      this.$api.Course.Vod.Videos.List(params).then((res) => {
        this.loading = false;
        this.list = res.data.videos.data;
        this.total = res.data.videos.total;
      });
    },
    close() {
      this.$emit("close");
    },
  },
};
</script>
