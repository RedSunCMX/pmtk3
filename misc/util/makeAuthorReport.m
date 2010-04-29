function report = makeAuthorReport(location)
% Generate an HTML report of the files contributed by other authors.

searchTags = {'PMTKauthor','PMTKurl','PMTKdate', 'PMTKtitle'};
searchNames = {'author', 'url', 'date', 'title'};
sortKey = 1;  % i.e. by author


if(nargin < 1)
    location = 'C:\kmurphy\pmtkLocal\doc\authors\';
end
fname = 'authors.html';

makeDestinationDir();


report = formatReport(generateReport());
%publishReport(report);


    function report = generateReport()
        % Generate the actual report as a struct
        report = createStruct(searchNames);
        mfnames = mfiles(pmtk3Root(), 'fullPath', true);
        counter = 1;
        for i=1:numel(mfnames)
            file = mfnames{i};
            increment = false;
            [tags, lines] = tagfinder(file, searchTags);
            if(~isempty(tags))
                for j=1:numel(searchTags)
                    tagNDX = findname(searchTags{j},tags);
                    if(~isempty(tagNDX))
                        fieldtext = lines{tagNDX(1)};
                        if(isempty(fieldtext))
                            fieldtext = ' ';
                        end
                        report(counter).(searchNames{j}) = fieldtext;
                        increment = true;
                    end
                end
                if(increment)
                    report(counter).file = file;
                    counter = counter + 1;
                end
            end
        end
    end


    function freport = formatReport(report)
        % Format the report
        sortvals = {report.(searchNames{sortKey})};
        emptyNDX = find(cell2mat(cellfuncell(@(x)isempty(x),sortvals)));
        emptyReport = report(emptyNDX);
        report(emptyNDX) = [];
        [val,perm] = sortrows(strvcat(report.(searchNames{sortKey}))); %#ok
        freport = [report(perm),emptyReport];
    end

    function publishReport(report)
        % Publish the report
        d = date;
        fid = fopen(fullfile(location,fname),'w+');
        fprintf(fid,'<html>\n');
        fprintf(fid,'<head>\n');
        fprintf(fid,'<font align="left" style="color:#990000"><h2>Contributing Authors</h2></font>\n');
        fprintf(fid,'<br>Revision Date: %s<br>\n',d);
        fprintf(fid,'<br>Auto-generated by makeAuthorReport.m<br>\n');
        fprintf(fid,'</head>\n');
        fprintf(fid,'<body>\n\n');
        fprintf(fid,'<br>\n');
        setupTable(fid,{'AUTHOR','FILE/PACKAGE NAME','SOURCE URL', 'DATE'},[40,40,10,10]);
        hprintf = @(txt)fprintf(fid,'\t<td> %s               </td>\n',txt);
        lprintf = @(link,name)fprintf(fid,'\t<td> <a href="%s"> %s </td>\n',link,name);
        for i=1:numel(report)
            fprintf(fid,'<tr bgcolor="white" align="left">\n');
            author = report(i).author;
            url    = report(i).url;
            file   = report(i).file;
            cdate  = report(i).date;
            title  = report(i).title;
            try
                system(sprintf('copy %s %s',which(file),location));
            catch ME %#ok
                fprintf('\nCould not copy %s',file);
            end
            if(isequal(author,' ') || isempty(author))
                hprintf('&nbsp;');
            else
                hprintf(author);
            end
            if isempty(title)
                lprintf(['./',file],file);
            else
                hprintf(title);
            end
            if(isequal(url,' ') || isempty(url))
                hprintf('&nbsp;');
            else
                lprintf(url,'website');
            end
            if(isequal(cdate,' ') || isempty(cdate))
                hprintf('&nbsp;');
            else
                hprintf(cdate);
            end
            fprintf(fid,'</tr>\n');
        end
        fprintf(fid,'</table>');
        fprintf(fid,'\n</body>\n');
        fprintf(fid,'</html>\n');
        fclose(fid);
    end

    function setupTable(fid,names,widths)
        % Setup an HTML table with the specified field names and widths in percentages
        fprintf(fid,'<table width="100%%" border="3" cellpadding="5" cellspacing="2" >\n');
        fprintf(fid,'<tr bgcolor="#990000" align="center">\n');
        for i=1:numel(names)
            fprintf(fid,'\t<th width="%d%%">%s</th>\n',widths(i),names{i});
        end
        fprintf(fid,'</tr>\n');
    end

    function makeDestinationDir()
        try cd(location)   % See if it already exists if not, create it
        catch ME %#ok
            err = system(['mkdir ',location]);
            if(err)            % if could not create it, error
                error('Unable to create destination directory at %s',destination);
            end
        end
    end
end