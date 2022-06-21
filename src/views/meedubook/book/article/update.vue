<template>
  <div class="meedu-main-body">
    <back-bar class="mb-30" title="编辑电子书文章"></back-bar>

    <div class="float-left" v-if="article && book">
      <el-form
        ref="form"
        class="float-left"
        :model="article"
        :rules="rules"
        label-width="200px"
      >
        <el-form-item prop="book_cid" label="章节">
          <div class="d-flex">
            <div>
              <el-select class="w-300px" clearable v-model="article.book_cid">
                <el-option
                  v-for="(item, index) in chapters"
                  :key="index"
                  :label="item.name"
                  :value="item.id"
                >
                </el-option>
              </el-select>
            </div>
            <div class="ml-10">
              <p-link
                text="章节管理"
                p="addons.meedu_books.book_chapter.list"
                type="primary"
                @click="
                  $router.push({
                    name: 'MeedubookChapter',
                    query: { bid: book_id },
                  })
                "
              ></p-link>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="标题" prop="title">
          <el-input
            v-model="article.title"
            class="w-300px"
            placeholder="请输入标题"
          ></el-input>
        </el-form-item>

        <el-form-item label="上架时间" prop="published_at">
          <div class="d-flex">
            <div>
              <el-date-picker
                style="width: 300px"
                v-model="article.published_at"
                type="datetime"
                format="yyyy-MM-dd HH:mm"
                value-format="yyyy-MM-dd HH:mm"
                placeholder="请选择日期"
              >
              </el-date-picker>
            </div>
            <div class="ml-10">
              <helper-text text="上架时间越晚，排序越靠前"></helper-text>
            </div>
          </div>
        </el-form-item>

        <el-form-item label="试看" prop="charge" v-if="book.charge > 0">
          <div class="d-flex">
            <div>
              <el-switch
                v-model="form.trySee"
                :active-value="true"
                :inactive-value="false"
              >
              </el-switch>
            </div>
            <div class="ml-10">
              <helper-text
                text="开启试看的话未购买电子书学员可直接浏览该篇文章。"
              ></helper-text>
            </div>
          </div>
        </el-form-item>

        <el-form-item label="隐藏文章">
          <div class="d-flex">
            <div>
              <el-switch
                v-model="article.is_show"
                :active-value="0"
                :inactive-value="1"
              >
              </el-switch>
            </div>
            <div class="ml-10">
              <helper-text
                text="打开后电子书文章在前台隐藏显示。"
              ></helper-text>
            </div>
          </div>
        </el-form-item>

        <el-form-item prop="original_content" label="文章内容">
          <div class="d-flex w-800px">
            <mavon-editor
              v-if="article.editor === 'MARKDOWN'"
              :content="article.original_content"
              :height="500"
              @change="getcontent"
            ></mavon-editor>
            <quill-editor
              v-else
              v-model="article.original_content"
              :height="458"
            ></quill-editor>
          </div>
        </el-form-item>
      </el-form>

      <div class="bottom-menus">
        <div class="bottom-menus-box">
          <div>
            <el-button @click="formValidate" :loading="loading" type="primary"
              >保存</el-button
            >
          </div>
          <div class="ml-24">
            <el-button @click="$router.back()">取消</el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import MavonEditor from "@/components/md-editor";
import QuillEditor from "@/components/quill-editor";

export default {
  components: {
    MavonEditor,
    QuillEditor,
  },
  data() {
    return {
      article_id: this.$route.query.id,
      book_id: this.$route.query.bid,
      article: null,
      form: {
        trySee: false,
      },
      rules: {
        title: [
          {
            required: true,
            message: "标题不能为空",
            trigger: "blur",
          },
        ],
        original_content: [
          {
            required: true,
            message: "内容不能为空",
            trigger: "blur",
          },
        ],
        published_at: [
          {
            required: true,
            message: "上架时间不能为空",
            trigger: "blur",
          },
        ],
      },
      chapters: [],
      loading: false,
      book: null,
    };
  },
  watch: {
    "form.trySee"() {
      this.article.charge = this.form.trySee ? 0 : 1;
    },
  },
  mounted() {
    this.params();
    this.getDetail();
    this.getBook();
  },
  methods: {
    getcontent(pureContent, renderContent) {
      this.article.original_content = pureContent;
      this.article.render_content = renderContent;
    },
    params() {
      this.$api.Meedubook.Book.Article.Create().then((res) => {
        this.chapters = res.data.chapters[this.book_id];
      });
    },
    getDetail() {
      this.$api.Meedubook.Book.Article.Detail(this.article_id).then((res) => {
        this.article = res.data;
        this.form.trySee = this.article.charge === 0;
        if (this.article.book_cid === 0) {
          this.article.book_cid = null;
        }
      });
    },
    getBook() {
      this.$api.Meedubook.Book.Detail(this.book_id).then((res) => {
        this.book = res.data;
      });
    },
    formValidate() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.confirm();
        }
      });
    },
    confirm() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      if (this.article.editor !== "MARKDOWN") {
        this.article.render_content = this.article.original_content;
      }
      this.$api.Meedubook.Book.Article.Update(this.article_id, this.article)
        .then(() => {
          this.$message.success(this.$t("common.success"));
          this.$router.back();
        })
        .catch((e) => {
          this.loading = false;
          this.$message.error(e.message);
        });
    },
  },
};
</script>
