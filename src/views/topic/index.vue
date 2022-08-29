<template>
  <div class="meedu-main-body">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <p-button
          text="新建图文"
          @click="$router.push({ name: 'TopicCreate' })"
          type="primary"
          p="addons.meedu_topics.topic.store"
        >
        </p-button>
        <p-button
          text="图文分类"
          @click="
            $router.push({
              name: 'TopicCategory',
            })
          "
          type="primary"
          p="addons.meedu_topics.category.list"
        >
        </p-button>
        <p-button
          text="图文评论"
          @click="$router.push({ name: 'TopicComment' })"
          type="primary"
          p="addons.meedu_topics.comments"
        >
        </p-button>
        <option-bar
          text="图文推荐"
          value="SystemTopicConfig"
          :query="{ referer: this.$route.path }"
        ></option-bar>
      </div>
      <div class="d-flex">
        <div>
          <el-input
            class="w-150px"
            v-model="filter.keywords"
            placeholder="图文关键字"
          ></el-input>
        </div>

        <div class="ml-10">
          <el-select
            placeholder="分类"
            class="w-150px"
            v-model="filter.category_id"
          >
            <el-option
              v-for="(item, index) in filterData.courses"
              :key="index"
              :label="item.name"
              :value="item.id"
            >
            </el-option>
          </el-select>
        </div>
        <div class="ml-10">
          <el-button @click="paginationReset">清空</el-button>
          <el-button @click="firstPageLoad" type="primary">筛选</el-button>
        </div>
      </div>
    </div>
    <div class="float-left" v-loading="loading">
      <div class="float-left">
        <el-table
          :header-cell-style="{ background: '#f1f2f9' }"
          :data="list"
          @sort-change="sortChange"
          :default-sort="{ prop: 'id', order: 'descending' }"
          class="float-left"
        >
          <el-table-column prop="id" sortable label="ID" min-width="6%">
          </el-table-column>
          <el-table-column label="图文" min-width="21%">
            <template slot-scope="scope">
              <thumb-bar
                :value="scope.row.thumb"
                :width="120"
                :height="90"
                :title="scope.row.title"
              ></thumb-bar>
            </template>
          </el-table-column>
          <el-table-column prop="category.name" label="分类" min-width="8%">
          </el-table-column>
          <el-table-column
            label="价格"
            sortable
            property="charge"
            min-width="7.5%"
          >
            <template slot-scope="scope">
              <span v-if="scope.row.charge > 0">{{ scope.row.charge }}元</span>
              <span v-else>免费</span>
            </template>
          </el-table-column>
          <el-table-column
            label="销量"
            sortable
            property="user_count"
            min-width="7.5%"
          >
            <template slot-scope="scope">
              <span>{{ scope.row.user_count }}</span>
            </template>
          </el-table-column>
          <el-table-column
            label="阅读"
            sortable
            property="view_times"
            min-width="7.5%"
          >
            <template slot-scope="scope">
              <span>{{ scope.row.view_times }}次</span>
            </template>
          </el-table-column>
          <el-table-column
            prop="vote_count"
            sortable
            label="点赞"
            min-width="7.5%"
          >
          </el-table-column>
          <el-table-column sortable label="上架时间" min-width="14%">
            <template slot-scope="scope">{{
              scope.row.sorted_at | dateFormat
            }}</template>
          </el-table-column>
          <el-table-column label="是否显示" min-width="8%">
            <template slot-scope="scope">
              <span class="c-green" v-if="scope.row.is_show === 1">· 显示</span>
              <span class="c-red" v-else>· 隐藏</span>
            </template>
          </el-table-column>
          <el-table-column
            fixed="right"
            label="操作"
            min-width="13%"
            align="right"
          >
            <template slot-scope="scope">
              <p-link
                text="编辑"
                type="primary"
                @click="
                  $router.push({
                    name: 'TopicUpdate',
                    query: { id: scope.row.id },
                  })
                "
                p="addons.meedu_topics.topic.update"
              ></p-link>
              <p-link
                text="学员"
                class="ml-5"
                type="primary"
                @click="
                  $router.push({
                    name: 'TopicOrder',
                    query: { id: scope.row.id },
                  })
                "
                p="addons.meedu_topics.orders"
              ></p-link>
              <el-dropdown>
                <el-link type="primary" class="el-dropdown-link ml-5">
                  更多<i class="el-icon-arrow-down el-icon--right"></i>
                </el-link>
                <el-dropdown-menu slot="dropdown">
                  <p-dropdown-item
                    text="删除"
                    p="addons.meedu_topics.topic.delete"
                    type="danger"
                    @click="destory(scope.row.id)"
                  >
                  </p-dropdown-item>
                </el-dropdown-menu>
              </el-dropdown>
            </template>
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
</template>

<script>
export default {
  data() {
    return {
      pageName: "topic-list",
      pagination: {
        page: 1,
        size: 10,
        sort: "id",
        order: "desc",
      },
      filter: {
        category_id: null,
        user_id: null,
        keywords: null,
      },
      total: 0,
      loading: false,
      list: [],
      filterData: {
        courses: [],
      },
    };
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
    firstPageLoad() {
      this.pagination.page = 1;
      this.getData();
    },
    paginationReset() {
      this.pagination.page = 1;
      this.filter.category_id = null;
      this.filter.user_id = null;
      this.filter.keywords = null;
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
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Course.Topic.Topic.List(params).then((res) => {
        this.loading = false;
        this.list = res.data.data.data;
        this.total = res.data.data.total;
        this.filterData.courses = res.data.categories;
      });
    },
    destory(item) {
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
          this.$api.Course.Topic.Topic.Destory(item)
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
  },
};
</script>
