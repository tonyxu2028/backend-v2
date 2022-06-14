<template>
  <div class="meedu-main-body">
    <div class="float-left j-b-flex mb-30">
      <div class="d-flex">
        <p-button
          text="新建电子书"
          p="addons.meedu_books.book.store"
          @click="$router.push({ name: 'MeedubookCreate' })"
          type="primary"
        >
        </p-button>
        <p-button
          text="电子书分类"
          p="addons.meedu_books.book_category.list"
          @click="$router.push({ name: 'MeedubookCategory' })"
          type="primary"
        >
        </p-button>
        <p-button
          text="电子书评论"
          p="addons.meedu_books.book.comments.list"
          @click="$router.push({ name: 'MeedubookComment' })"
          type="primary"
        >
        </p-button>
        <p-button
          text="文章评论"
          p="addons.meedu_books.book_article.comments.list"
          @click="$router.push({ name: 'MeedubookArticleComment' })"
          type="primary"
        >
        </p-button>
        <option-bar text="电子书推荐" value="电子书"></option-bar>
      </div>
      <div class="d-flex">
        <div>
          <el-input
            class="w-150px"
            v-model="filter.key"
            placeholder="电子书关键字"
          ></el-input>
        </div>
        <div class="ml-10">
          <el-select v-model="filter.cid" class="w-150px" placeholder="分类">
            <el-option
              v-for="(item, index) in filterData.categories"
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
          :data="mbooks"
          @sort-change="sortChange"
          :default-sort="{ prop: 'id', order: 'descending' }"
          class="float-left"
        >
          <el-table-column prop="id" sortable label="ID" min-width="6%">
          </el-table-column>
          <el-table-column label="电子书" min-width="30%">
            <template slot-scope="scope">
              <thumb-bar
                :value="scope.row.thumb"
                :width="90"
                :height="120"
                :title="scope.row.name"
              ></thumb-bar>
            </template>
          </el-table-column>
          <el-table-column prop="category.name" label="分类" min-width="10%">
          </el-table-column>
          <el-table-column
            label="价格"
            property="charge"
            sortable
            min-width="7%"
          >
            <template slot-scope="scope">
              <span>{{ scope.row.charge }}元</span>
            </template>
          </el-table-column>

          <el-table-column
            label="销量"
            property="user_count"
            sortable
            min-width="7%"
          >
            <template slot-scope="scope">
              <span>{{ scope.row.user_count }}</span>
            </template>
          </el-table-column>
          <el-table-column
            label="阅读"
            property="view_times"
            sortable
            min-width="7%"
          >
            <template slot-scope="scope">
              <span>{{ scope.row.view_times }}次</span>
            </template>
          </el-table-column>
          <el-table-column label="上架时间" sortable min-width="13%">
            <template slot-scope="scope">{{
              scope.row.published_at | dateFormat
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
            min-width="12%"
            align="right"
          >
            <template slot-scope="scope">
              <p-link
                text="文章"
                p="addons.meedu_books.book_article.list"
                type="primary"
                @click="
                  $router.push({
                    name: 'MeedubookArticle',
                    query: { bid: scope.row.id },
                  })
                "
              ></p-link>
              <p-link
                text="学员"
                p="addons.meedu_books.book.users"
                type="primary"
                class="ml-5"
                @click="
                  $router.push({
                    name: 'MeedubookUsers',
                    query: { bid: scope.row.id },
                  })
                "
              ></p-link>
              <el-dropdown>
                <el-link type="primary" class="el-dropdown-link ml-5">
                  更多<i class="el-icon-arrow-down el-icon--right"></i>
                </el-link>
                <el-dropdown-menu slot="dropdown">
                  <p-dropdown-item
                    text="编辑"
                    p="addons.meedu_books.book.update"
                    type="primary"
                    @click="
                      $router.push({
                        name: 'MeedubookUpdate',
                        query: { id: scope.row.id },
                      })
                    "
                  >
                  </p-dropdown-item>
                  <p-dropdown-item
                    text="删除"
                    type="danger"
                    @click="destory(scope.row.id)"
                    p="addons.meedu_books.book.delete"
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
      pageName: "book-list",
      pagination: {
        page: 1,
        size: 10,
        sort: "id",
        order: "desc",
      },
      filter: {
        key: null,
        cid: null,
      },
      total: 0,
      loading: false,
      mbooks: [],
      filterData: {
        categories: [],
      },
    };
  },
  activated() {
    this.getBook();
    this.$utils.scrollTopSet(this.pageName);
  },
  beforeRouteLeave(to, from, next) {
    this.$utils.scrollTopRecord(this.pageName);
    next();
  },
  methods: {
    paginationReset() {
      this.pagination.page = 1;
      this.filter.key = null;
      this.filter.cid = null;
      this.getBook();
    },
    paginationSizeChange(size) {
      this.pagination.page = 1;
      this.pagination.size = size;
      this.getBook();
    },
    paginationPageChange(page) {
      this.pagination.page = page;
      this.getBook();
    },
    firstPageLoad() {
      this.pagination.page = 1;
      this.getBook();
    },
    sortChange(column) {
      this.pagination.sort = column.prop;
      this.pagination.order = column.order === "ascending" ? "asc" : "desc";
      this.getBook();
    },
    getBook() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      let params = {};
      Object.assign(params, this.filter);
      Object.assign(params, this.pagination);
      this.$api.Meedubook.Book.List(params).then((res) => {
        this.loading = false;
        this.mbooks = res.data.data.data;
        this.total = res.data.data.total;
        this.filterData.categories = res.data.categories;
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
          this.$api.Meedubook.Book.Destory(item)
            .then(() => {
              this.loading = false;
              this.$message.success(this.$t("common.success"));
              this.paginationReset();
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

<style lang="less" scoped>
.filter-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  padding: 30px;
  border-radius: 15px;
  margin-bottom: 15px;
  background-color: white;

  .filter-label {
    font-size: 14px;
    color: rgba(0, 0, 0, 0.7);
  }
}
</style>
