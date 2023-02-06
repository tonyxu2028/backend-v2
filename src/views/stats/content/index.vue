<template>
  <div class="el_content">
    <div class="el_top_row1">
      <div class="el_row_item">
        <div class="header">
          <div class="tabs">
            <el-button-group>
              <el-button
                :type="filter.goods_type === item.key ? 'primary' : ''"
                v-for="item in typeList"
                :key="item.id"
                @click="handleClickBtnE(item)"
                >{{ item.name }}</el-button
              >
            </el-button-group>
          </div>
          <div class="controls">
            <day-week-month @change="changeTimeContentTop"></day-week-month>
          </div>
        </div>
        <div class="float-left mt-15" v-loading="loading">
          <el-table
            :header-cell-style="{ background: '#f1f2f9' }"
            :data="list"
            class="float-left"
          >
            <el-table-column label="TOP10销量">
              <template slot-scope="scope">
                <span>{{ scope.row.goods_name }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="orders_count" label="支付订单数" width="250">
            </el-table-column>
            <el-table-column
              prop="orders_paid_sum"
              label="支付总金额"
              width="250"
            >
            </el-table-column>
          </el-table>
        </div>
        <div class="float-left mt-30 text-center">
          <el-pagination
            @size-change="paginationSizeChange"
            @current-change="paginationPageChange"
            :current-page="pagination.page"
            :page-sizes="[10, 20, 50, 100]"
            :page-size="pagination.size"
            layout="total, sizes, prev, pager, next, jumper"
            :total="total"
          >
          </el-pagination>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import moment from "moment";
import { mapState } from "vuex";
import DayWeekMonth from "@/components/day-week-month";
export default {
  components: {
    DayWeekMonth,
  },
  data() {
    return {
      pageName: "stats-member-list",
      list: [],
      loading: false,
      total: 0,
      pagination: {
        page: 1,
        size: 10,
      },
      filter: {
        start_at: moment().format("YYYY-MM-DD"),
        end_at: moment().add(1, "days").format("YYYY-MM-DD"),
        goods_type: "COURSE",
      },
    };
  },
  computed: {
    ...mapState(["enabledAddons", "user"]),
    typeList() {
      let typeList = [
        {
          name: "录播课",
          key: "COURSE",
        },
      ];
      if (this.enabledAddons["Zhibo"]) {
        typeList.push({
          name: "直播课",
          key: "直播课程",
        });
      }
      if (this.enabledAddons["LearningPaths"]) {
        typeList.push({
          name: "学习路径",
          key: "学习路径",
        });
      }
      if (this.enabledAddons["MeeduBooks"]) {
        typeList.push({
          name: "电子书",
          key: "BOOK",
        });
      }
      if (this.enabledAddons["MeeduTopics"]) {
        typeList.push({
          name: "图文",
          key: "文章",
        });
      }

      return typeList;
    },
  },
  mounted() {
    this.getData();
  },
  methods: {
    paginationReset() {
      this.pagination.page = 1;
      this.filter.start_at = moment().format("YYYY-MM-DD");
      this.filter.end_at = moment().add(1, "days").format("YYYY-MM-DD");
      this.filter.goods_type = "COURSE";
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
    handleClickBtnE(item) {
      this.filter.goods_type = item.key;
      this.paginationPageChange(1);
    },
    getData() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Stats.Content.List(params).then((res) => {
        this.loading = false;
        this.list = res.data.data;
        this.total = res.data.total;
      });
    },
    changeTimeContentTop(start_at, end_at) {
      this.filter.start_at = start_at;
      this.filter.end_at = end_at;
      this.paginationPageChange(1);
    },
  },
};
</script>
<style lang="less" scoped>
.el_content {
  min-width: 1169px;
  width: 100%;
  height: 100%;
  position: relative;
  display: flex;
  flex-direction: column;
  .el_top_row1 {
    width: 100%;
    height: auto;
    display: flex;
    flex-direction: row;
    position: relative;
    .el_row_item {
      width: 100%;
      height: auto;
      overflow: hidden;
      background: #ffffff;
      box-shadow: 0px 2px 4px 0px rgba(102, 102, 102, 0.05);
      border-radius: 8px;
      padding: 16px 30px 30px 30px;
      box-sizing: border-box;
      position: relative;
      display: flex;
      flex-direction: column;
      margin-bottom: 20px;
      .header {
        width: 100%;
        display: flex;
        flex-direction: row;
        position: relative;
        align-items: center;
        justify-content: space-between;
      }
    }
  }
}
</style>
